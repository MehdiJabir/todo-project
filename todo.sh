#!/bin/bash


#I tried to be as thorough and clear as possible with my documentation & explanation.

TASKS_FILE="tasks.txt"

#Checks if the tasks file exists, creates it if not
if [ ! -f "$TASKS_FILE" ]; then
    touch "$TASKS_FILE"
fi
ID=0

validate_date() {
    local date_input=$1
    local current_year=$(date +%Y)
    local year=$(echo $date_input | cut -d'-' -f1)
    local month=$(echo $date_input | cut -d'-' -f2)
    local day=$(echo $date_input | cut -d'-' -f3)

    #Checks the overall date format first
    if ! [[ $date_input =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Invalid date format. Please use YYYY-MM-DD."
        return 1
    fi

    #Check the year range (last 100 years)
    if (( year < current_year - 100 || year > current_year )); then
        echo "Year must be within the last 100 years."
        return 1
    fi

    #Checks the month range
    if (( month < 1 || month > 12 )); then
        echo "Month must be between 01 and 12."
        return 1
    fi

    #Check the day range
    if (( day < 1 || day > 31 )); then
        echo "Day must be between 01 and 31."
        return 1
    fi

    return 0
}

validate_time() {
    local time_input=$1
    local hour=$(echo $time_input | cut -d':' -f1)
    local minute=$(echo $time_input | cut -d':' -f2)

    
    if ! [[ $time_input =~ ^([0-1][0-9]|2[0-3]):([0-5][0-9])$ ]] #0-24:0-59 
     then
        echo "Invalid time format. Please use HH:MM, 24-hour format."
        return 1
    fi
    return 0
}

create() {
    if [ -f "$TASKS_FILE" ]; then
        ID=$(tail -1 "$TASKS_FILE" | cut -d',' -f1)
        ID=$((ID + 1))
    fi

    read -p "Enter new task's title: " title
    if [ -z "$title" ]; then
        echo "Title can't be empty" >&2
        exit 3
    fi

    read -p "Enter task description (default 'none'): " desc
    desc=${desc:-none}

    read -p "Enter task location (default 'null'): " location
    location=${location:-null}

    read -p "Enter due date (format YYYY-MM-DD): " due_date
     if ! validate_date "$due_date"
      then
        exit 3
        fi
    if [ -z "$due_date" ]; then
        echo "Due date is required." >&2
        exit 3
    fi

    read -p "Enter due time (format HH:MM, default '00:00'): " due_time
    due_time=${due_time:-00:00}

    completion="not complete"
    echo "$ID,$title,$desc,$location,$due_date,$due_time,$completion" >> "$TASKS_FILE"
    echo "Task created successfully with ID $ID"
}


show() {
    #prompting for id
    read -p "Enter the task ID you want to display: " task_id
    if [ -z "$task_id" ]; then
        echo "Task ID cannot be empty" >&2
        exit 4
    fi

    #searchs for the task using ID 
     task=$(grep "^$task_id," "$TASKS_FILE")
    if [ -z "$task" ]; then
        echo "No task found with ID $task_id" >&2
        exit 4
    fi

    #Splitting the task details for our output
    id=$(echo "$task" | cut -d',' -f1)
    title=$(echo "$task" | cut -d',' -f2)
    desc=$(echo "$task" | cut -d',' -f3)
    location=$(echo "$task" | cut -d',' -f4)
    due_date=$(echo "$task" | cut -d',' -f5)
    due_time=$(echo "$task" | cut -d',' -f6)
    completion=$(echo "$task" | cut -d',' -f7)

    #displaying the task details
    echo "Task ID: $id"
    echo "Title: $title"
    echo "Description: $desc"
    echo "Location: $location"
    echo "Due Date: $due_date"
    echo "Due Time: $due_time"
    echo "Completion Status: $completion"
}

delete() {
    
    read -p "Enter the task ID you want to delete: " task_id
    if [ -z "$task_id" ]; then
        echo "Task ID cannot be empty" >&2
        exit 5
    fi

    
    if ! grep -q "^$task_id," "$TASKS_FILE"
    then
        echo "No task found with ID $task_id" >&2
        exit 5
    fi

    
    sed -i "/^$task_id,/d" "$TASKS_FILE" #-i modifies it without any output, deleting the file row starting with the id of my choice
    
    if [ $? -eq 0 ]
    then
        echo "Task with ID $task_id deleted successfully."
    else
        echo "Failed to delete task with ID $task_id" >&2
        exit 5
    fi
}
update() {
    show  #Calls the  show function to display and set global variables that will be used in the update function

    
    if [ -z "$task" ]; then
        exit  6
    fi

    #Prompt for new values, use current if left blank
    echo "Current title: $title"
    read -p "Enter new title (or leave empty to keep current): " new_title
    new_title=${new_title:-$title}

    echo "Current description: $desc"
    read -p "Enter new description (or leave empty to keep current): " new_desc
    new_desc=${new_desc:-$desc}

    echo "Current location: $location"
    read -p "Enter new location (or leave empty to keep current): " new_location
    new_location=${new_location:-$location}

    echo "Current due date: $due_date"
    read -p "Enter new due date (or leave empty to keep current): " new_due_date
     if [ -n "$new_due_date" ]
     then
        if validate_date "$new_due_date"
        then
            due_date=$new_due_date
        else
            echo "Invalid date entered. Update canceled."
            return 6
        fi
    fi

     echo "Current due time: $due_time"
    read -p "Enter new due time (format HH:MM, default '00:00'): " new_due_time
    if [ -n "$new_due_time" ]; then
        if validate_time "$new_due_time"; then
            due_time=$new_due_time
        else
            echo "Invalid time entered. Update canceled."
            return 6  
        fi
    fi

    echo "Current completion status: $completion"
    read -p "Enter new completion status (or leave empty to keep current): " new_completion
    new_completion=${new_completion:-$completion}

    #assembling the new attributes for the updated task, then updating
    updated_task="$id,$new_title,$new_desc,$new_location,$new_due_date,$new_due_time,$new_completion"
    sed -i "s/^$id,.*/$updated_task/" "$TASKS_FILE"
    if [ $? -eq 0 ]
    then
        echo "Task with ID $id updated successfully."
    else
    echo "Error when updating" >&2
    exit 6
    fi
}

find() {
    read -p "Enter the task title you want to find: " title
    if [ -z "$title" ]; then
        echo "Task title cannot be empty" >&2
        return 7
    fi

     title=$(echo "$title" | xargs | sed 's/[]\/$*.^[]/\\&/g')  #escaping regex chars

    echo "Searching for tasks with titles containing '$title':"
    #grep to search case-insensitively for the title anywhere in the title field
    local tasks_found=$(grep -i -E "^[^,]*,[[:space:]]*[^,]*$title[^,]*," "$TASKS_FILE")

    if [ -z "$tasks_found" ]; then
        echo "No task found with title containing '$title'" >&2
        return 7
    fi

    echo "Tasks matching title containing '$title':"
    echo "$tasks_found" | while IFS=',' read -r id t desc location due_date due_time completion; do
        echo "Task ID: $id"
        echo "Title: $t"
        echo "cue Date: $due_date"
        echo "completion Status: $completion"
    
    done
    echo "for more information regarding each task, please use the todo show <id>"
}


list(){
    local input_date="$1"  #Date is passed as an argument

    if [ -z "$input_date" ]; then
        input_date=$(date '+%Y-%m-%d')  #Default to today's date if no argument
    fi

    if [ ! -s "$TASKS_FILE" ]; then
        echo "No tasks found. The task file is empty or does not exist."
        return 8
    fi

    echo "Tasks for date $input_date:"
    
    local completed_tasks=""
    local uncompleted_tasks=""

    while IFS=',' read -r id title desc location due_date due_time completion; do
        if [ "$due_date" == "$input_date" ]; then
            local task_details="Task ID: $id\nTitle: $title\nDescription: $desc\nLocation: $location\nDue Date: $due_date\nDue Time: $due_time\nCompletion Status: $completion\n-----------------------------------------------------------------"
            if [ "$completion" == "complete" ]; then
                completed_tasks+="$task_details"
            else
                uncompleted_tasks+="$task_details"
            fi
        fi
    done < "$TASKS_FILE"

    if [ -n "$uncompleted_tasks" ]; then
        echo -e "Uncompleted Tasks:\n$uncompleted_tasks"
    else
        echo "No uncompleted tasks for this date."
    fi

    if [ -n "$completed_tasks" ]; then
        echo -e "Completed Tasks:\n$completed_tasks"
    else
        echo "No completed tasks for this date."
    fi
}

help() {
    echo "User Manual for Task Management Script"
    echo "Introduction:"
    echo "  This script provides a simple interface to manage tasks stored in the tasks.txt file."
    echo ""
    echo "Features:"
    echo "  - Create a Task:"
    echo "    - Command: ./todo.sh create"
    echo "    - Description: Prompts for task details like title , description, location, due date, and due time."
    echo ""
    echo "  - Delete a Task:"
    echo "    - Command: ./todo.sh delete"
    echo "    - Description: Deletes a task by its ID."
    echo ""
    echo "  - Update a Task:"
    echo "    - Command: ./todo.sh update"
    echo "    - Description: Updates details for a task. Fields left blank are not changed."
    echo ""
    echo "  - Find a Task by Title:"
    echo "    - Command: ./todo.sh find"
    echo "    - Description: Finds and displays tasks by title."
    echo ""
    echo "  - Show Task Details:"
    echo "    - Command: ./todo.sh show"
    echo "    - Description: Shows detailed information for a task by its ID."
    echo ""
    echo "  - List Tasks:"
    echo "    - Command: ./todo.sh list"
    echo "    - Description: Lists tasks for a given date or today if no date is provided."
    echo ""
    echo "Additional Commands:"
    echo "  - Help:"
    echo "    - Command: ./todo.sh help or ./todo.sh ?"
    echo "    - Description: Displays this help manual."
    echo ""
    echo "Exit Codes:"
    echo "  - 0: Successful operation."
    echo "  - 1: Invalid command or arguments."
    echo "  - 2: Invalid Number of arguments"
    echo "  - 3: Error related to creating tasks, such as duplicate title or missing required fields."
    echo "  - 4: Error related to showing tasks"
    echo "  - 5: Error related to deleting tasks"
    echo "  - 6: Error related to updating tasks"
    echo "  - 7: Error related to finding tasks"
    echo "  - 8: Error related to listing tasks"

    echo ""
    echo "General Usage:"
    echo "  - To use the script, navigate to its directory and run it with the desired command."
    echo "  - Example: ./todo.sh create"
    echo "  - Ensure you have execution permissions: chmod +x todo.sh"
    echo " ALL DATES MUST FOLLOW YYYY-MM-DD FORMAT"
}

#MAIN:
if [ $#-eq 0 ]
then
    list
elif [ $#-eq 1 ] 
then 
    case $1 in
        [Cc]reate)
            create;; #task creation
        [Dd]elete)
            delete;; #task deletion
        [Ff]ind)
            find;; #finding task by title, and displaying info/details
        [Ss]how)
            show;; #shows task details using id
        [Ll]ist)
            read -p "Enter the date (YYYY-MM-DD) to list tasks, or press Enter for today: " date
            list;; #lists all tasks
        [Uu]pdate)
            update;; #updates task details using id
        "?"|"help"|"Help")
            help;; #Explains what "todo" does and how it works, like a manual
        *)
            echo "Invalid argument, use './todo ?' to consult the manual">&2
            exit 1;;
    esac
    exit 0
else 
    echo "Invalid number of arguments, use './todo ?' to consult the manual">&2
    exit 2;
fi



