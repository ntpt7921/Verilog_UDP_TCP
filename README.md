# Verilog_UDP_TCP_IP

## Mô tả chung

Đây là phần bài làm cho chủ đề "Hiện thực giải mã/đóng gói gói tin" của Đồ án thiết kế luận lí học kì II/2021 ĐHBK-HCM.

Nội dung được hiện thực là gói tin của các giao thức [IPv4](https://en.wikipedia.org/wiki/IPv4), [TCPv4](https://en.wikipedia.org/wiki/Transmission_Control_Protocol), [UDPv4](https://en.wikipedia.org/wiki/User_Datagram_Protocol) ('v4' ở đây có nghĩa là dựa theo IPv4). Mỗi gói tin sẽ được hiện thực ở hai module khác nhau, decoder - giải mã gói tin, và encoder - đóng gói gói tin. Các module được thiết kế để giảm thiểu sự phụ thuộc vào nhau ít nhất có thể, và riêng với các module decoder có thể kiểm thử một cách độc lập nếu cung cấp đủ các input.

## Sắp xếp và đặt tên file

Mã Verilog cho các module và testbench tương ứng của chúng được chứa trong các tệp `UDP`, `TCP`, `IP` và `Common`. Các tệp `UDP`, `TCP`, `IP` sẽ chứa riêng các module lớn của từng phần. Tệp `Common` dùng để chứa các module nhỏ dùng chung cho toàn dự án.

Tệp `Documetation` chứa các tài liệu và ghi chú phục vụ cho việc hiện thực. Nó chứa ghi chú chi tiết cho giao thức UDP và IP, sơ đồ khối của toàn hệ thống (chưa có, cần bổ sung), sơ đồ khối từng gói tin lớn (chưa có, cần bổ sung) và các tài liệu liên quan.

Tệp `Report` chứa các file phục vụ việc viết báo cáo tổng kết (hiện chưa bắt đầu).

Với mỗi module được dùng, tồn tại một file hiện thực được đặt tên `<tên module>.v` và một file testbench được đặt tên `<tên module>_tb.v`. Chi tiết các module, sẽ được ghi trong comment của file hiện thực (chưa có, cần bổ sung comment).

## Chạy file Verilog

Trình biên dịch và mô phỏng được chọn dùng là Icarus Verilog. Để chạy các file testbench trên Linux (ngầm định đã cài đặt `iverilog`):
```
iverilog -y ./Common -y ./UDP -y ./TCP -y ./IP -g2012 <tên testbench>.v
vvp a.out
```
trong đây `-y <tên tệp>` được dùng để liệt kê các tệp thư viện và trình biên dịch sẽ dùng để tìm module bị thiếu, `-g2012` dùng để báo rằng chuẩn được dùng sẽ là SystemVerilog (IEEE 1800-2012) - phần mở rộng thêm chỉ dùng để viết testbench. `iverilog` sẽ xuất ra một file (trường hợp này là `a.out`). Để chạy file này ta dùng `vvp`.

## Tiến độ

- Tài liệu
  - [x] UDP
  - [ ] TCP
  - [ ] IP
  - [ ] Sơ đồ khối kiến trúc hệ thông
- UDP
  - [x] Decoder
  - [x] Encoder 
- TCP
  - [ ] Decoder
  - [ ] Encoder 
- IP
  - [ ] Decoder
  - [ ] Encoder
