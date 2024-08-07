new data recovery strategy offers a smooth and efficient methodology for recording and reconstructing database operations. 
This approach is based on a central audit table that captures all operations (INSERT, UPDATE, DELETE) on any table, using two main columns (old_value, new_value) to store data in JSONB format. 
A metadata table records the details of all database columns and is dedicated to data reconstruction
![image](https://github.com/user-attachments/assets/8684f14c-eee6-4337-aa8c-b94de63de2e0)
![image](https://github.com/user-attachments/assets/9e836288-5e1e-4715-8996-12e89c54c3bc)
![image](https://github.com/user-attachments/assets/a87215f5-960f-4073-8758-6f6004681bbd)
