# todo-project
Todo Task Manager
Introduction
The Todo Task Manager is a command-line script designed for efficiently managing todo tasks. It supports functionalities like creation, updating, deletion, and viewing of tasks, as well as listing by date and searching by title.

Design Choices:
Data Storage:
Tasks:
Tasks are stored in tasks.txt, where each task is represented as a single line with fields separated by the comma (,) character. The fields include:

ID: Unique identifier for each task, generated automatically by incrementing the id of the last task in the task file.
Title: Title of the task (required).
Description: Task description (optional).
Location: Location for the task (optional).
Due Date: Task due date in YYYY-MM-DD format (required).
Due Time: Time the task is due in HH:MM format (optional).
Completion Status: Indicates if the task is "completed" or "not completed" ("not completed" by default).
Code Organization
create()
Generates a new task ID, then prompts the user to input task details. It uses read to capture user input for titles. The function ensures the input for required fields is not empty, and validates date and time formats using regular expressions.

Commands Used:

read: Captures user input.
echo: Writes to files.
Regular expressions: Validate formats of inputs.


show()
Retrieves and displays detailed information about a task. It uses grep to find the task by ID and then formats each field using echo.

Commands Used:

grep: Searches for the specific task ID in the task file.


delete()
Prompts the user for a task ID to delete, confirms the action, and then deletes the task using sed. It lists all tasks before deletion to assist the user in choosing the correct ID.

Commands Used:

sed: Deletes lines from the file that match the given task ID.


update()
Allows the user to update existing task details by first listing the task and asking for the ID of the task to update. Uses grep to fetch the task's current details and read to get new values. The sed command is used for updating inline, replacing specific fields without altering others.

Commands Used:

sed: Performs in-place editing of the task line.


find()
Searches for tasks by their title using a case-insensitive match. It uses grep to filter tasks where the title matches the search query.

Commands Used:

grep: Filters and displays tasks that match the title search criteria.


list()
Lists tasks for a specified date, categorizing them into completed and uncompleted. This function uses awk to filter tasks by date and completion status.

Commands Used:

grep: Filters based on titles containing the input

help()
Displays the help manual with detailed instructions on how to use the script.

Commands Used:

echo: Displays help information.

How to Run the Program

Clone the repository:
git clone [https://github.com/MehdiJabir/todo-project.git](https://github.com/MehdiJabir/todo-project.git)
Make the script executable:

chmod +x todo.sh
Execute various commands:

Create a task:
./todo.sh create

Delete a task:
./todo.sh delete

Find a task by title:
./todo.sh find

Show task details:
./todo.sh show

List tasks:
./todo.sh list

Update a task:
./todo.sh update

Display help:
./todo.sh help

Contributing
We welcome contributions! Please fork the repository and submit pull requests with your improvements.
