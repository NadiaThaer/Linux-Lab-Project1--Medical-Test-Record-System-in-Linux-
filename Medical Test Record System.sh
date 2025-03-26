echo "Welcome to First project in Linux Lab  Nadia Saja  "
echo "-----------------------------------------------------"
filename="midecalRecord.txt"  
########################################################################################################################

menue()
{
echo "0.Read Files"
echo "1.Add a new medical test record"
echo "2.Search for a test by patient ID"
echo "3.Searching for up normal tests"
echo "4.Average test value"
echo "5.Update an existing test result"
echo "6.Delet the test"
echo "7.EXIT :( "
} 
readFile()
{
# Check if the File Exist or not
if [ -e "$filename" ]
then
    echo "File '$filename' exists."
    echo "The file Contain this data:"
   
   echo "-----------------------------------------------------"
    while read line
do
echo $line
done < $filename

echo "-----------------------------------------------------"
else
    echo "File '$filename' does not exist,Try to enter the correct name of file"
fi

}
############################################################################################################################################################

Add_Record() {
>nameTest.txt
    while true; do
        echo "Enter Patient ID (7 digits):"
        read patient_id

        # Check if the patient ID is valid
        if [[ $patient_id =~ ^[0-9]{7}$ ]]; then
            break  # Exit the loop if valid
        else
            echo "Invalid ID. It may contain alphabets or the length is not 7 digits. Try again."
        fi
    done
while read -r record; do
    # Extract the test name
    test_name=$(echo "$record" | cut -d':' -f2 | cut -d',' -f1 | xargs)
    
    # Check if the test name already exists in nameTest.txt
    if grep -q "^$test_name$" nameTest.txt; then
        continue  # Skip this test name if it already exists
    fi
    
    # Add the test name to nameTest.txt
    echo "$test_name" >> nameTest.txt
done < midecalRecord.txt

######################################################################################################################################################3
while true; do
    echo "Enter Test Name:"
    read test_name

    # Trim leading and trailing spaces
    test_name=$(echo "$test_name" | xargs)

    # Check if the test name exists in the nameTest file (case-insensitive)
    if grep -qi "^${test_name}$" nameTest.txt; then
        echo "Valid Test Name: $test_name"
        break  # Exit the loop if valid
    else
        echo "Invalid Test Name. Please enter a valid test name from the following list:"
        cat nameTest.txt
        echo "Try again."
    fi
done
    echo "Enter Test Date (YYYY-MM):"
    read test_date

    echo "Enter Test Result:"
    read result

    echo "Enter Status (Pending/Completed/Reviewed):"
    read status
# Append new record to the file
echo "$patient_id: $test_name, $test_date, $result,$status" >> midecalRecord.txt

# Display the contents of the file
echo "The midecalRecord.txt after added new Recored"
cat midecalRecord.txt

    
 echo "Record added successfully."
}
#############################################################################################################################################################

search_For_Up_normal() {
    # Clear upnormal.txt file
    > upnormal.txt
 #####################################################################################

    # Loop through each line in medicalRecord.txt
    while IFS=":" read -r patient_id line; do
        # Extract test_name and test_result
        test_name=$(echo "$line" | cut -d"," -f1 | tr -d ' ')
        test_result=$(echo "$line" | cut -d"," -f3 | tr -d ' ')

        # Loop through each line in medicalTest.txt to find the upper value for the test
        #notice :testname befor :
        #IFS >> work like -d":"
        while IFS=":" read -r test_name_medical range; do
          # Remove any white space
            test_name_medical=$(echo "$test_name_medical" | tr -d ' ')

            # Extract the upper value from the range
            #Notice Very Important point : xargs to ensure that the final output without any spacing :without it the output will be  >
            upper_value=$(echo "$range" | cut -d',' -f2 | cut -d'<' -f2 | cut -d';' -f1 | xargs)
            unit=$(echo "$range" | cut -d"," -f4 | tr -d ' ')

            # Check if the test_name from medicalRecord matches the test_name from medicalTest
            if [[ "$test_name" == "$test_name_medical" ]]; then
                # Compare the test result and upper value
                 test_result=$(printf "%.0f" "$test_result")
                  upper_value=$(printf "%.0f" "$upper_value")
                if [ "$test_result" -gt  "$upper_value" ]; then
                    # Write the abnormal result to upnormal.txt
                    echo "Patient ID: $patient_id" >> upnormal.txt
                    echo "Test Name: $test_name" >> upnormal.txt
                    echo "Test Result: $test_result" >> upnormal.txt
                    echo "Upper Value: $upper_value" >> upnormal.txt
                    echo "Upper Value: $upper_value < Test Result: $test_result ,so this is upnormal test ." >> upnormal.txt
                    echo "##############################################################################################" >> upnormal.txt
                fi
                # This search for the same name Test with patient
                break
            fi
        done < medicalTest.txt

    done < midecalRecord.txt

    # Display the content of upnormal.txt
    cat upnormal.txt
}
#####################################################################################################################################################

searchByID() {

    while true; do
        echo "Enter the Patient ID you want to search for:"
        read ID
        if [[ $ID =~ ^[0-9]{7}$ ]]; then
            echo "Searching for Patient ID: $ID"
            echo "Choose an option:"
            echo "1. Retrieve all patient tests"
            echo "2. Retrieve all abnormal patient tests"
            echo "3. Retrieve all patient tests in a given specific period"
            echo "4. Retrieve all patient tests based on test status"
            read option

            case $option in
                1)
                    echo "All tests for Patient ID: $ID"
                    grep "$ID" "$filename"
                    ;;
                2)
                    echo "All abnormal tests for Patient ID: $ID"
                    grep "$ID" "$filename" | grep -E 'Reviewed|Pending'
                    ;;
                3)
                    echo "Enter the period (YYYY-MM) to filter the tests:"
                    read period
                    echo "All tests for Patient ID: $ID in the period $period"
                    grep "$ID" "$filename" | grep "$period"
                    ;;
                4)
                    echo "Enter the status (e.g., Completed, Pending, Reviewed) to filter the tests:"
                    read status
                    echo "All tests for Patient ID: $ID with status $status"
                    grep "$ID" "$filename" | grep "$status"
                    ;;
                *)
                    echo "Invalid option, returning to menu."
                    ;;
            esac

            if [ $? -ne 0 ]; then
                echo "No records found for Patient ID: $ID with the chosen option."
            fi
            break
        else
            echo "Invalid ID. It must contain exactly 7 digits. Please try again."
        fi
    done
}

##################################################################################################################################################3
updateTestResult(){
    cat -n "$filename"
    echo ""
    echo "Enter the line number where you want to update the test result:"
    read lineNumber

    # Extract the old test result value from the specified line
    oldTestResult=$(sed -n "${lineNumber}p" "$filename" | cut -d ',' -f3)
    echo "Old test result: $oldTestResult"

    echo "Please enter the new test result value:"
    read newTestResult

    # Check if the old value exists in the specified line
    if sed -n "${lineNumber}p" "$filename" | grep -q "$oldTestResult"; then
        # Replace the old test result value with the new one in the specified line
        sed -i "${lineNumber}s/$oldTestResult/$newTestResult/" "$filename"
        echo "Updated line $lineNumber with the new value."
        echo "Updated line:"
        sed -n "${lineNumber}p" "$filename"
    else
        echo "The value $oldTestResult was not found in line $lineNumber."
    fi
}
#####################################################################################################################################################
calculateAverageTest() {
    if [ -e "$filename" ]; then
        totalTests=$(wc -l < "$filename")

        if [ "$totalTests" -eq 0 ]; then
            echo "The file is empty, no tests to calculate percentages."
            return
        fi

        # Initialize associative array to store test counts
        declare -A testCounts

        while IFS=',' read -r id name date value unit status; do
            if [ -n "$name" ]; then
                testCounts["$name"]=$((testCounts["$name"] + 1))
            fi
        done < "$filename"

        echo "Test percentages:"
        for testName in "${!testCounts[@]}"; do
            testCount=${testCounts["$testName"]}
            percentage=$(echo "scale=2; ($testCount / $totalTests) * 100" | bc)
            echo "$testName: $percentage%"
        done
    else
        echo "File '$filename' does not exist."
    fi
}
###############################################################################################################################################################3
delete_test_record() {
    # Prompt the user to enter the patient ID
    echo  "Enter the ID of the patient whose test you want to delete: "
    read patient_id

    # Check if the patient ID exists in the record
    if grep -q "^$patient_id:" midecalRecord.txt; then
        echo "Tests for Patient ID $patient_id:"
        # Display the tests for that patient ID
        grep "^$patient_id:" midecalRecord.txt

        # Prompt the user to enter the test name they want to delete
        echo -n "Enter the name of the test you want to delete: "
        read test_name

        # Delete the test record for the specific patient and test name
        if grep -q "^$patient_id: $test_name," midecalRecord.txt; then
            sed -i "/^$patient_id: $test_name,/d" midecalRecord.txt
            echo "Test '$test_name' for Patient ID $patient_id has been deleted."
            cat midecalRecord.txt
        else
            echo "Test '$test_name' not found for Patient ID $patient_id."
        fi
    else
        echo "Patient ID $patient_id not found."
    fi
}


option=0
while [ "$option" -ne -1 ]; do
    menue
    read option
    case $option in
        0)
            echo "Enter the filename you want to read:"
            read filename
            readFile
            ;;
        1)Add_Record
            ;;
        2)searchByID
            ;;
        3)search_For_Up_normal;;
        4)calculateAverageTest
            ;;
        5)updateTestResult
            ;;
        6)   delete_test_record;;
        7)
            echo "Exiting..."
            option=-1
            ;;
        *)echo "this is invalid Choise try again --->"
    esac
done






###########################################################























