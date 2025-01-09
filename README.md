new data recovery strategy offers a smooth and efficient methodology for recording and reconstructing database operations. 
This approach is based on a central audit table that captures all operations (INSERT, UPDATE, DELETE) on any table, using two main columns (old_value, new_value) to store data in JSONB format. 
A metadata table records the details of all database columns and is dedicated to data reconstruction

![blackhole_1](https://github.com/user-attachments/assets/63265857-e273-47fe-9309-b3c2a6ebba93)
![blackhole_2](https://github.com/user-attachments/assets/d726a69a-6517-467c-931d-1fd90784d3b4)
![blackhole_3](https://github.com/user-attachments/assets/05198467-efc0-4eaa-9ce6-8cb5f2e03ac0)
