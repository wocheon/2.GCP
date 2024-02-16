## GCP Instance Group

## 1. 인스턴스 그룹 유형별 구분
- 관리형과 비관리형으로 구분

### 비관리형 인스턴스 그룹
- 다수의 인스턴스를 논리적으로 그룹화 한 것
- 로드밸런서로 연결가능해짐

### 관리형 인스턴스 그룹 (MIG)
- 고가용성
    - 실패한 VM 자동 복구 ( VM 중지/충돌/선점/삭제 시 재생성 )
    - 애플리케이션 기반 자동 복구 ( Application 체크 및 미응답시 VM 재생성)
    - 리전(멀티 영역) 노출 범위 (앱 부하 분산 가능)
    - 부하 분산 ( 트래픽 분산 )

- 확장성
    - 인스턴스 오토스케일링 지원

- 자동 업데이트
    - 새로운 버전의 소프트웨어를 MIG에 배포가능 
        - 순차적,카나리아 등의 업데이트 옵션 지원

- 스테이트풀(Stateful) 워크로드 지원
    - Stateful 구성을 사용하는 Application의 배포 빌드 및 작업  자동화 가능




2. scale-in, scale-out 방법 정리

3. 확장 일정 관리


4. 공휴일 확장일정 변경 스크립트 

>vi restday_schedule_change.sh

```bash
#!/bin/bash

today=$(date '+%y%m%d')
log_file="/root/gcp_schedule_change/logs/change_schedule_${today}.log"

#exec >> $log_file

# Function And Load Array
source /root/gcp_schedule_change/restday_list.txt

function in_array {
        for e in ${rest_date[*]}
        do
                if [[ "$e" == $1 ]]
                then
                        return 0
                fi
        done

        return 1
}

function load_vm_schedule {
        gcloud compute instance-groups managed describe scheduled-vm --zone=asia-northeast3-a | sed -n '/scalingScheduleStatus/,/selfLink/p' |  grep -v -e scalingScheduleStatus -e lastStartTime -e nextStartTime -e selfLink > /root/gcp_schedule_change/gcloud_schedule_state
}


# Load GCP VM Schedule State

load_vm_schedule

schedule_monday=$(sed -n '2p' gcloud_schedule_state | gawk -F": " '{print $2}')
schedule_tuesfri=$(sed -n '4p' gcloud_schedule_state | gawk -F": " '{print $2}')
schedule_weekday=$(sed -n '6p' gcloud_schedule_state | gawk -F": " '{print $2}')

echo "###GCP VM Schedule States###"
echo "schedule-monday : $schedule_monday"
echo "schedule-tues-fri : $schedule_tuesfri"
echo "schedule-weekday : $schedule_weekday"
echo ""

if ( [ $schedule_monday = "ACTIVE" ] || [ $schedule_monday = "READY" ] ) \
   && ( [ $schedule_tuesfri = "ACTIVE" ] || [ $schedule_tuesfri = "READY" ] ) \
   && ( [ $schedule_weekday = "ACTIVE" ] || [ $schedule_weekday = "READY" ] ); then
        state="enabled"
elif [ $schedule_monday = "DISABLED" ] && [ $schedule_tuesfri = "DISABLED" ] && [ $schedule_weekday = "DISABLED" ]; then
        state="disabled"
else
        echo "!ERROR : Check Schedule State!!"
        exit 0
fi


# define Date vars

today_md=$(echo $today | cut -c 3-6)
yesterday_md=$(date -d "${today} -1day" '+%y%m%d' | cut -c 3-6)
tommorow_md=$(date -d "${today} +1day" '+%y%m%d' | cut -c 3-6)

#Tommorow Restday check
if in_array $tommorow_md; then
        tommorow_wr="Restday"
else
        tommorow_wr="Workday"
fi


# Change State
if [ $state = "enabled" ]; then
        change_state="disabled"
else
        change_state="enabled"
fi


# Today Restday Check
echo "###Today Restday Check###"

if [ $state = 'enabled' ] && [ $tommorow_wr = "Restday" ]; then
        echo "! Need to Change State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        echo " Change Schedule to $change_state !"
        change="o"

elif [ $state = 'disabled' ] && [ $tommorow_wr = "Workday" ]; then
        echo "! Need to Change State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        echo " Change Schedule to $change_state !"
        change="o"
else
        echo "Keep Present State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        change="x"
        #rm -f $log_file
fi


# Change State
if [ $change = "o" ]; then
#        read -p "Change Schedule State ? (y/n) " ans
#       if [ $ans = "y" ]; then

                if [ $change_state = 'disabled' ]; then
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --disable-schedule=schedule-monday
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --disable-schedule=schedule-tues-fri
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --disable-schedule=schedule-weekday
                elif [ $change_state = 'enabled' ]; then
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --enable-schedule=schedule-monday
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --enable-schedule=schedule-tues-fri
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --enable-schedule=schedule-weekday
                fi

                echo "State Changed : $change_state"
                echo "* Please Check few Minuate Later (Udate Schedule Spend Few Minuate)"

                #load_vm_schedule
                #cat gcloud_schedule_state
        #else
        #       echo "state not changed"
        #fi
fi
```