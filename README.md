# **BudgetMe - Ứng dụng Quản lý Chi Tiêu Cá Nhân**

**Tên dự án**: **BudgetMe**  
**Nhóm thực hiện**:
- Nguyễn Khánh Toàn 
- Trần Lê Xuân My 
- Nguyễn Hương Giang 
- Phạm Mai Chi 
- Hứa Tuấn Vĩ 
- Trần Phương Nghi 

**Ngày báo cáo**: [31/11/2024]

---

## **1. Giới thiệu Dự án**

### **1.1 Mục tiêu Dự án**
**BudgetMe** là một ứng dụng di động giúp người dùng quản lý tài chính cá nhân bằng cách ghi nhận và theo dõi các khoản thu chi. Mục tiêu của ứng dụng là cung cấp một công cụ đơn giản, dễ sử dụng, giúp người dùng quản lý tài chính hiệu quả và có cái nhìn tổng quan về tình hình tài chính cá nhân của mình.

Ứng dụng cho phép người dùng:
- Ghi lại các khoản thu/chi với các chi tiết như số tiền, danh mục, ngày tháng, và ghi chú.
- Xem lịch sử các giao dịch đã thực hiện.
- Thống kê và phân tích chi tiêu qua các báo cáo tài chính.

### **1.2 Lý do chọn Dự án**
- **Tính cần thiết**: Quản lý tài chính cá nhân là một nhu cầu thiết yếu, tuy nhiên nhiều ứng dụng hiện tại chưa đáp ứng được yêu cầu của người dùng về tính đơn giản và tiện lợi.
- **Học hỏi**: Dự án này không chỉ giúp nhóm học hỏi về lập trình di động và phát triển ứng dụng, mà còn giúp rèn luyện kỹ năng làm việc nhóm và giải quyết vấn đề trong thực tế.

---

## **2. Tính năng của Ứng dụng**

1. **Thêm giao dịch mới**:
    - Người dùng có thể ghi lại các giao dịch thu hoặc chi, với thông tin chi tiết như số tiền, danh mục, ngày tháng và ghi chú.

2. **Danh sách giao dịch**:
    - Người dùng có thể xem lại tất cả các giao dịch đã thực hiện trong quá khứ. Danh sách được sắp xếp theo thứ tự thời gian, giúp người dùng dễ dàng tra cứu.

3. **Báo cáo tài chính**:
    - Cung cấp thống kê về các khoản thu chi theo ngày, tuần hoặc tháng. Biểu đồ đơn giản giúp người dùng dễ dàng nhìn thấy tình hình tài chính của mình.

4. **Lưu trữ dữ liệu trên thiết bị**:
    - Dữ liệu về các giao dịch và báo cáo tài chính được lưu trữ cục bộ trên thiết bị, đảm bảo bảo mật và không cần kết nối internet.

5. **Phân loại giao dịch**:
    - Người dùng có thể phân loại các giao dịch theo các danh mục như ăn uống, đi lại, giải trí, thu nhập, v.v.

---

## **3. Công nghệ sử dụng**

- **Flutter**: Framework phát triển ứng dụng đa nền tảng (Android, iOS). Flutter giúp phát triển giao diện người dùng đẹp mắt và hiệu suất tốt.
- **Dart**: Ngôn ngữ lập trình chính dùng cho Flutter, giúp xây dựng logic và các chức năng của ứng dụng.
- **SQLite**: Hệ thống quản lý cơ sở dữ liệu nhẹ, cục bộ để lưu trữ thông tin giao dịch và báo cáo tài chính.
- **Figma**: Công cụ thiết kế UI/UX cho ứng dụng, giúp tạo ra các giao diện người dùng dễ sử dụng và đẹp mắt.

---

## **4. Quy trình Phát triển**

### **4.1 Các bước thực hiện**
1. **Phân tích yêu cầu**:
    - Đầu tiên, nhóm tiến hành phân tích và xác định các tính năng cốt lõi cần có trong ứng dụng. Các yêu cầu bao gồm việc ghi lại giao dịch, hiển thị danh sách giao dịch và báo cáo tài chính.

2. **Thiết kế UI/UX**:
    - Sau khi xác định yêu cầu, nhóm tiến hành thiết kế giao diện người dùng với Figma. Giao diện phải đơn giản, dễ sử dụng và đẹp mắt, phù hợp với đối tượng người dùng.

3. **Xây dựng Cơ sở dữ liệu**:
    - Cơ sở dữ liệu được xây dựng bằng SQLite để lưu trữ thông tin về các giao dịch và báo cáo tài chính. Các bảng cơ sở dữ liệu được thiết kế để dễ dàng truy vấn và cập nhật thông tin.

4. **Lập trình ứng dụng**:
    - Các tính năng chính như thêm giao dịch, hiển thị danh sách giao dịch và báo cáo tài chính được lập trình bằng Flutter/Dart. Đồng thời, logic của ứng dụng được xử lý bằng Dart và kết nối với cơ sở dữ liệu SQLite.

5. **Kiểm thử và sửa lỗi**:
    - Sau khi hoàn thành các tính năng, ứng dụng được kiểm thử kỹ lưỡng để phát hiện và sửa lỗi. Các tính năng như thêm giao dịch, hiển thị danh sách và báo cáo được kiểm tra kỹ để đảm bảo hoạt động chính xác.

### **4.2 Phân chia công việc**
| **Thành viên**             | **Nhiệm vụ**                                               |  
|---------------------------|-----------------------------------------------------------|  
| Nguyễn Khánh Toàn         | Nhóm trưởng, sửa logic, kết nối UI với cơ sở dữ liệu      |  
| Trần Lê Xuân My           | Thiết kế UI/UX bằng Figma, hỗ trợ thiết kế cơ sở dữ liệu  |  
| Nguyễn Hương Giang        | Phát triển cơ sở dữ liệu                                   |  
| Phạm Mai Chi              | Phát triển cơ sở dữ liệu                                   |  
| Hứa Tuấn Vĩ               | Xây dựng logic xử lý các tính năng trong ứng dụng         |  
| Trần Phương Nghi          | Lập trình giao diện người dùng, các màn hình của ứng dụng |

---

## **5. Kết quả Đạt được**

1. **Các tính năng hoàn thiện**:
    - Giao diện người dùng đơn giản và dễ sử dụng.
    - Các tính năng cơ bản đã hoàn thiện: thêm giao dịch, xem lịch sử giao dịch, thống kê tài chính.

2. **Giao diện đơn giản, dễ sử dụng**:
    - Các màn hình được thiết kế tối giản, giúp người dùng dễ dàng thực hiện các thao tác mà không gặp phải khó khăn.

3. **Ứng dụng ổn định và hiệu quả**:
    - Ứng dụng hoạt động ổn định, không gặp phải lỗi nghiêm trọng trong quá trình thử nghiệm.

### **5.1 Demo giao diện ứng dụng**
- **Màn hình chính**: Danh sách giao dịch thu chi với các nút thao tác nhanh.
- **Màn hình thêm giao dịch**: Các trường nhập thông tin giao dịch như số tiền, danh mục, ngày tháng.
- **Màn hình báo cáo**: Thống kê chi tiêu với các biểu đồ đơn giản.


## **6. Đánh giá và Bài học Kinh nghiệm**

### **6.1 Đánh giá**
- **Ưu điểm**:
    - Ứng dụng dễ sử dụng và tiện lợi cho người dùng quản lý chi tiêu.
    - Giao diện đơn giản, dễ hiểu, dễ thao tác.
    - Ứng dụng hoạt động ổn định, không có lỗi nghiêm trọng.

- **Hạn chế**:
    - Ứng dụng chưa có tính năng đồng bộ với cloud, chỉ lưu trữ dữ liệu cục bộ trên thiết bị.
    - Các báo cáo tài chính có thể được cải thiện với các biểu đồ phân tích chi tiết hơn.

### **6.2 Bài học kinh nghiệm**
- Phân chia công việc rõ ràng và quản lý thời gian là rất quan trọng để hoàn thành dự án đúng tiến độ.
- Kiểm thử và sửa lỗi là một bước không thể thiếu trong phát triển phần mềm, giúp ứng dụng ổn định và dễ sử dụng.
- Làm việc nhóm hiệu quả và phối hợp giữa các thành viên giúp giải quyết vấn đề nhanh chóng.

---

## **7. Hướng phát triển**

1. **Đồng bộ hóa dữ liệu**:
    - Tích hợp tính năng đồng bộ dữ liệu với cloud để đảm bảo dữ liệu có thể truy cập từ nhiều thiết bị khác nhau và luôn được bảo vệ.

2. **Cải tiến báo cáo tài chính**:
    - Thêm tính năng phân tích chi tiết hơn với các biểu đồ trực quan, giúp người dùng hiểu rõ tình hình tài chính của mình.

3. **Hỗ trợ đa ngôn ngữ**:
    - Thêm tính năng hỗ trợ nhiều ngôn ngữ để mở rộng đối tượng người dùng, đặc biệt là người dùng quốc tế.

---

## **8. Kết luận**

**BudgetMe** là một ứng dụng rất hữu ích cho việc quản lý chi tiêu cá nhân, giúp người dùng theo dõi tài chính một cách đơn giản và trực quan. Dự án mang lại nhiều bài học quý báu trong quá trình phát triển ứng dụng và làm việc nhóm. Nhóm phát triển dự định sẽ tiếp tục phát

triển và cải thiện ứng dụng trong tương lai.

---

## **9. Thông tin Liên hệ**

- **GitHub Repository**: [BudgetMe trên GitHub](https://github.com/nguyenktoan/chitieu)
- **Nhóm phát triển**:
    - Nguyễn Khánh Toàn (Nhóm trưởng) 
    - Trần Lê Xuân My (Figma/Database)
    - Nguyễn Hương Giang (Database)
    - Phạm Mai Chi (Database)
    - Hứa Tuấn Vĩ (Logic)
    - Trần Phương Nghi (Code UI)



