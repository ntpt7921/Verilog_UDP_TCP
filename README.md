# Verilog_UDP_TCP

## Mô tả chung

Đây là phần bài làm cho chủ đề "Hiện thực giải mã/đóng gói gói tin" của Đồ án thiết kế luận lí học kì II/2021 ĐHBK-HCM.

Nội dung được hiện thực là gói tin của các giao thức [IPv4](https://en.wikipedia.org/wiki/IPv4), [TCPv4](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) và [UDPv4](https://en.wikipedia.org/wiki/User_Datagram_Protocol) ('v4' ở đây có nghĩa là dựa theo IPv4). Mỗi gói tin sẽ được hiện thực ở hai module khác nhau, decoder - giải mã gói tin, và encoder - đóng gói gói tin. Các module được thiết kế để có thể thực hiện được riêng chức năng của mình, giảm thiểu sự phụ thuộc vào nhau. Các module có thể được kiểm thử một cách độc lập nếu cung cấp đủ các input.

## Sắp xếp và đặt tên file

Mã Verilog cho các module và testbench tương ứng của chúng được chứa trong các tệp `Combine`, `IP`, `UDP`, `TCP`, `Common` và `Testbench`. Các tệp `Combine`, `IP`, `UDP`, `TCP` sẽ chứa riêng các module lớn của từng phần. Tệp `Common` dùng để chứa các module nhỏ dùng chung cho toàn dự án. Tệp `Testbench` chứa các file testbench cho từng module được viết. Với mỗi module được dùng, tồn tại một file hiện thực được đặt tên `<tên module>.v` và một file testbench được đặt tên `<tên module>_tb.v`.

Về phần `Combine`, đây là phần nối tổng hợp lại cái module IP, TCP và UDP đã viết để tạo thành bộ phận giải mã và đóng gói gói tin hoàn chỉnh. Phần này có thể được thực hiện sau khi đã viết xong các bộ phận cần thiết.

Tệp `Documetation` chứa các tài liệu và ghi chú phục vụ cho việc hiện thực. Nó chứa ghi chú chi tiết cho giao thức UDP, TCP và IP, sơ đồ khối của toàn hệ thống (tức sơ đồ khối của các module phần combine), sơ đồ khối và state diagram từng gói tin lớn (các module UDP, TCP và IP) và các tài liệu liên quan. Các module lớn của các phần IP, TCP, UDP sẽ có state diagram với tên `<tên module>_sd.svg`. Đồng thời các module trên cũng sẽ có sơ đồ khối với tên `<tên module>_bd.svg`.

Tệp `Report` chứa các file phục vụ việc viết báo cáo tổng kết (hiện chưa bắt đầu).

## Chạy file Verilog

Trình biên dịch và mô phỏng được chọn dùng là Icarus Verilog. Để chạy các file testbench trên Linux (ngầm định đã cài đặt `iverilog` và đang đứng tại thư mục gốc của dự án):
```
iverilog -y ./Common -y ./UDP -y ./TCP -y ./IP -y ./Combine -g2012 ./Testbench/<tên testbench>.v
vvp a.out
```
trong đây `-y <tên tệp>` được dùng để liệt kê các tệp thư viện và trình biên dịch sẽ dùng để tìm module được sử dụng, `-g2012` dùng để báo rằng chuẩn được dùng sẽ là SystemVerilog (IEEE 1800-2012) - phần mở rộng thêm này chỉ dùng để viết testbench. Lệnh `iverilog` sẽ xuất ra một file (trường hợp này là `a.out`). Để chạy file này ta dùng `vvp`.

## Tiến độ

- Tài liệu
  - [x] UDP
  - [x] TCP
  - [x] IP
  - [ ] Sơ đồ khối các khối tin lớn
  - [x] Sơ đồ khối kiến trúc hệ thông
  - [x] State diagram
- UDP
  - [x] Decoder
  - [x] Encoder 
- TCP
  - [x] Decoder
  - [x] Encoder
- IP
  - [x] Decoder
  - [x] Encoder
- Combine
  - [x] Decoder
  - [x] Encoder
