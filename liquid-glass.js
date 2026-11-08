(() => {
  "use strict";
  const MAX_SURFACES = 8;
  const SELECTORS = [".hero", ".panel", ".search-box"];
  const DPR_CAP = 1.75;

  const vertexSource = `#version 300 es
  precision highp float;
  const vec2 POSITIONS[3] = vec2[3](
    vec2(-1.0, -1.0), vec2(3.0, -1.0), vec2(-1.0, 3.0)
  );
  void main() { gl_Position = vec4(POSITIONS[gl_VertexID], 0.0, 1.0); }`;

  const fragmentSource = `#version 300 es
  precision highp float;
  out vec4 outColor;
  uniform vec2 u_resolution;
  uniform float u_time;
  uniform int u_count;
  uniform vec4 u_rects[8];
  uniform float u_radii[8];

  float roundedBox(vec2 p, vec2 halfSize, float radius) {
    vec2 q = abs(p) - halfSize + radius;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
  }

  vec3 environment(vec2 uv) {
    vec2 px = uv * u_resolution;
    vec3 base = mix(vec3(0.018, 0.045, 0.085), vec3(0.025, 0.075, 0.135), uv.y);
    float glowA = exp(-length((uv - vec2(0.14, 0.88)) * vec2(1.0, 1.25)) * 3.2);
    float glowB = exp(-length((uv - vec2(0.88, 0.70)) * vec2(1.2, 1.0)) * 3.6);
    base += vec3(0.035, 0.12, 0.22) * glowA;
    base += vec3(0.025, 0.075, 0.19) * glowB;
    vec2 dotPhase = fract(px / 30.0);
    vec2 dotGrid = min(dotPhase, 1.0 - dotPhase);
    float dots = 1.0 - smoothstep(0.025, 0.060, length(dotGrid));
    base += vec3(0.16, 0.28, 0.40) * dots * 0.42;
    vec2 gridPhase = fract(px / 72.0);
    vec2 grid = min(gridPhase, 1.0 - gridPhase);
    float gridLine = 1.0 - smoothstep(0.0, 0.018, min(grid.x, grid.y));
    base += vec3(0.08, 0.19, 0.30) * gridLine * 0.30;
    return base;
  }

  void main() {
    vec2 pixel = gl_FragCoord.xy;
    vec2 uv = pixel / u_resolution;
    vec4 result = vec4(0.0);

    for (int i = 0; i < 8; i++) {
      if (i >= u_count) break;
      vec4 rect = u_rects[i];
      vec2 center = rect.xy + rect.zw * 0.5;
      vec2 local = pixel - center;
      float radius = u_radii[i];
      float d = roundedBox(local, rect.zw * 0.5, radius);

      if (d <= 0.0) {
        float insideDistance = max(0.0, -d);
        float rim = 1.0 - smoothstep(0.0, 9.0, insideDistance);
        float softRim = exp(-insideDistance / 22.0);
        float wave = 0.5 + 0.5 * sin(uv.x * 5.0 + uv.y * 3.0 + u_time * 0.16);
        vec2 direction = vec2(0.0007, 0.00035) * (0.5 + wave);
        vec3 refracted = environment(uv + direction);
        vec3 tint = mix(vec3(0.43, 0.63, 0.88), refracted, 0.20);
        float alpha = 0.018 + rim * 0.095 + softRim * 0.012;
        vec3 highlight = vec3(0.72, 0.84, 1.0) * (rim * (0.10 + wave * 0.035));
        result = vec4(tint * 0.22 + highlight, alpha);
      }
    }

    outColor = result;
  }`;

  function compile(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      const message = gl.getShaderInfoLog(shader) || "Unknown shader error";
      gl.deleteShader(shader);
      throw new Error(message);
    }
    return shader;
  }

  function createProgram(gl) {
    const vertex = compile(gl, gl.VERTEX_SHADER, vertexSource);
    const fragment = compile(gl, gl.FRAGMENT_SHADER, fragmentSource);
    const program = gl.createProgram();
    gl.attachShader(program, vertex);
    gl.attachShader(program, fragment);
    gl.linkProgram(program);
    gl.deleteShader(vertex);
    gl.deleteShader(fragment);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      const message = gl.getProgramInfoLog(program) || "Unknown program link error";
      gl.deleteProgram(program);
      throw new Error(message);
    }
    return program;
  }

  function start() {
    if (document.getElementById("liquid-glass-webgl")) return;
    const canvas = document.createElement("canvas");
    canvas.id = "liquid-glass-webgl";
    canvas.setAttribute("aria-hidden", "true");
    Object.assign(canvas.style, {
      position: "fixed", inset: "0", width: "100%", height: "100%",
      zIndex: "0", pointerEvents: "none", display: "block"
    });
    document.body.prepend(canvas);

    const gl = canvas.getContext("webgl2", {
      alpha: true, antialias: false, depth: false, stencil: false,
      premultipliedAlpha: false, preserveDrawingBuffer: false,
      powerPreference: "high-performance"
    });
    if (!gl) {
      canvas.remove();
      console.info("[Liquid Glass] WebGL 2 unavailable; keeping CSS fallback.");
      return;
    }

    let program;
    try {
      program = createProgram(gl);
    } catch (error) {
      canvas.remove();
      console.error("[Liquid Glass] Shader initialization failed:", error);
      return;
    }

    const vao = gl.createVertexArray();
    gl.bindVertexArray(vao);
    gl.useProgram(program);
    const locations = {
      resolution: gl.getUniformLocation(program, "u_resolution"),
      time: gl.getUniformLocation(program, "u_time"),
      count: gl.getUniformLocation(program, "u_count"),
      rects: gl.getUniformLocation(program, "u_rects[0]"),
      radii: gl.getUniformLocation(program, "u_radii[0]")
    };

    document.body.classList.add("webgl-glass-ready");

    const surfaces = [];
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const selectors = SELECTORS.join(",");
    const resizeObserver = new ResizeObserver(markDirty);
    let dirty = true;
    let frame = 0;
    let lastFrame = 0;
    const frameInterval = 1000 / 30;
    const startTime = performance.now();

    function markDirty() { dirty = true; }

    function collectSurfaces() {
      const found = [...document.querySelectorAll(selectors)]
        .filter(element => {
          const rect = element.getBoundingClientRect();
          return rect.width > 2 && rect.height > 2;
        }).slice(0, MAX_SURFACES);
      surfaces.splice(0, surfaces.length, ...found);
      resizeObserver.disconnect();
      found.forEach(element => resizeObserver.observe(element));
      dirty = true;
    }

    function resizeCanvas() {
      const dpr = Math.min(window.devicePixelRatio || 1, DPR_CAP);
      const width = Math.max(1, Math.floor(window.innerWidth * dpr));
      const height = Math.max(1, Math.floor(window.innerHeight * dpr));
      if (canvas.width !== width || canvas.height !== height) {
        canvas.width = width;
        canvas.height = height;
        gl.viewport(0, 0, width, height);
        markDirty();
      }
      return dpr;
    }

    function draw(now) {
      frame = 0;
      if (document.hidden) return;
      if (!reducedMotion && now - lastFrame < frameInterval && !dirty) {
        frame = requestAnimationFrame(draw);
        return;
      }
      lastFrame = now;
      const dpr = resizeCanvas();
      if (dirty) collectSurfaces();

      gl.disable(gl.SCISSOR_TEST);
      gl.clearColor(0, 0, 0, 0);
      gl.clear(gl.COLOR_BUFFER_BIT);
      gl.useProgram(program);
      gl.bindVertexArray(vao);
      gl.uniform2f(locations.resolution, canvas.width, canvas.height);
      gl.uniform1f(locations.time, (now - startTime) / 1000);
      gl.enable(gl.BLEND);
      gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
      gl.enable(gl.SCISSOR_TEST);

      const rectData = new Float32Array(MAX_SURFACES * 4);
      const radii = new Float32Array(MAX_SURFACES);
      for (const element of surfaces) {
        const rect = element.getBoundingClientRect();
        if (rect.width <= 2 || rect.height <= 2) continue;

        const x = Math.max(0, Math.floor(rect.left * dpr));
        const y = Math.max(0, Math.floor((window.innerHeight - rect.bottom) * dpr));
        const width = Math.min(canvas.width - x, Math.ceil(rect.width * dpr));
        const height = Math.min(canvas.height - y, Math.ceil(rect.height * dpr));
        if (width <= 0 || height <= 0) continue;

        const radius = parseFloat(getComputedStyle(element).borderTopLeftRadius) || 16;
        rectData.fill(0);
        radii.fill(0);
        rectData[0] = rect.left * dpr;
        rectData[1] = (window.innerHeight - rect.bottom) * dpr;
        rectData[2] = rect.width * dpr;
        rectData[3] = rect.height * dpr;
        radii[0] = radius * dpr;

        gl.scissor(x, y, width, height);
        gl.uniform1i(locations.count, 1);
        gl.uniform4fv(locations.rects, rectData);
        gl.uniform1fv(locations.radii, radii);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
      }

      gl.disable(gl.SCISSOR_TEST);
      gl.disable(gl.BLEND);
      dirty = false;
      if (!reducedMotion) frame = requestAnimationFrame(draw);
    }

    function schedule() {
      if (!frame && !document.hidden) frame = requestAnimationFrame(draw);
    }

    window.addEventListener("resize", () => { markDirty(); schedule(); }, { passive: true });
    window.addEventListener("scroll", () => { markDirty(); schedule(); }, { passive: true, capture: true });
    document.addEventListener("visibilitychange", () => {
      if (document.hidden) {
        if (frame) cancelAnimationFrame(frame);
        frame = 0;
      } else {
        markDirty();
        schedule();
      }
    });
    document.addEventListener("transitionend", markDirty, true);
    document.addEventListener("animationend", markDirty, true);

    const mutationObserver = new MutationObserver(() => {
      collectSurfaces();
      schedule();
    });
    mutationObserver.observe(document.body, {
      childList: true, subtree: true, attributes: true,
      attributeFilter: ["class", "style"]
    });

    collectSurfaces();
    schedule();
    console.info("[Liquid Glass] WebGL 2 refraction prototype initialized.");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();