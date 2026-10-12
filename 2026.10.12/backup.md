•有一個原始檔 report.txt 和一個備份檔 report.bak。程式要判斷是否需要重新備份。
•如果 report.txt 不存在	→ 顯示 source file does not exist.
•如果 report.bak 不存在	→ 建立備份
•如果 report.txt 比 report.bak 新	→ 更新備份
•如果 report.txt 比 report.bak 舊	→ 不需備份
•如果兩者時間相同	→ 不需備份
