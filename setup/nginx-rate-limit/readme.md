# limit_req zone=[r100] burst=[30] [nodelay/delay=100];

# VD 2r/s 

2r/s có nghĩa là nginx sẽ lấy 1s chia cho 2 request = 500ms = trong 500ms chỉ có 1 request được cho là hợp lệ đến cùng một ip. 

Cứ mỗi 500ms chỉ được 1 request gửi đến, nếu trong 500ms có nhiều hơn 1 request thì request vượt mức sẽ bị loại bỏ và không thực hiện (503) 
tuy nhiên vì điều này khá bất cập dẫn đến sinh ra burst

# burst = 5

burst hiểu nhanh là hàng đợi , 5 ở đây có nghĩa là hàng đợi này có tối đa 5 request

theo VD ban đầu là 2r/s thì những request nào lúc đầu thay về bị trả về 503 sẽ được đưa vào hàng đợi và chờ để được xữ lý. Chỉ khi nào số hàng đợi không còn chỗ trống thì request đó mới bị trả về 503

VD theo ta set ban đầu 2r/s thì trong 500ms đầu chỉ tối đa được nhận 1 request. tuy nhiên nếu 500 ms ban đầu ta nhận được 3 request thì 1 request đầu tiên sẽ được xữ lý ngay lập tức, 2 request tiếp theo sẽ được đưa vào hàng đợi và cứ mỗi 500ms tiếp theo thì sẽ lấy ra 1 request để xữ lý. 

Lưu ý, 1 khi hàng đợi được kích hoạt thì các request sẽ được thực hiện thông qua hàng đợi chứ không xữ lý trực tiếp nữa. Có nghĩa là khi hàng đợi đã được kích hoạt và đang đợi để xữ lý nếu có thêm một số request mới thì các request này sẽ được đưa luôn vào hàng đợi 

=> Bất cập : VD ta có limit 2r/s và burst = 20 trong 500ms đầu có 21 request tới từ 1 ip thì 1 request sẽ được xữ lý, 20 cái request còn lại được đưa vào hàng đợi và cứ cách 500ms sẽ được thực hiện, việc này làm request thứ 21 được xử lý sau 20*500ms = 10000ms = 10s =)))) => sinh ra nodelay/delay


# nodelay/delay 

nôm na là số lượng request được thực hiện ngay khi số lượng request vượt quá rate limit

# nodelay :

no-delay =))) là không delay request. Theo như bất cập của burst bên trên thì việc chờ đợi của request vượt quá rate limit khá lâu nên mới sinh thêm cái thằng này. 

Bản chất của nodelay có nghĩa là khi chúng ta có 21 request đến trong cùng 500ms ban đầu thì :  

- tất cả 21 request này sẽ được xữ lý ngay lập tức
- đồng thời khởi tạo burst = 20 với full slot = 20 luôn . Mặc dù 21 request được xữ lý ngay lập tức nhưng burst vẫn coi như nó chưa được xữ lý và cứ 500ms nó sẽ giải phóng 1 vị trí trong burst - giống với việc mua vé trong rạp dù mình có coi hay không thì hết phim mới tới lượt người khác đặt ghế đó =)))

# delay 

khác với nodelay là thực hiện tất cả nhưng burst vẫn bị chiếm chỗ thì đối với delay sẽ thực hiện số request vượt quá được set, số còn lại thì đem vào burst

VD 2r/s burst=20 delay=5 

Trong 500ms đầu tiên có 21 request cùng đến thì :

- Xữ lý 1+5 request ngay lập tức (1 ở đây là 1 request hợp lệ + 5 request được vượt)
- Đưa số còn lại vào hàng đơi và cứ 500ms thì xữ lý 1 request 


