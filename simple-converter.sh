#!/usr/bin/env bash
#set -euo pipefail

# Regular expressions for number validation and definition format validation
re_number="^[+-]?[0-9]+\.?[0-9]*$"
re_string="^[a-z]*_to_[a-z]*$"

# File name to store definitions
file_name="definitions.txt"

# Create the file if it doesn't exist
touch "$file_name"

# Welcome message
echo -e "Welcome to the Simple converter!\n"

# Function to display the main menu
menu() {
  echo "Select an option"
  echo "0. Type '0' or 'quit' to end program"
  echo "1. Convert units"
  echo "2. Add a definition"
  echo "3. Delete a definition"
}

# Function to add a definition to the file
add_definition() {
  while true; do
    echo "Enter a definition:"
    read -r definition_input

    # Split the line into an array using spaces as the delimiter
    IFS=' ' read -r -a definition <<<"$definition_input"

    if [ "${#definition[@]}" -ne 2 ]; then
      echo "The definition is incorrect!"
    else
      local input="${definition[0]}"
      local num="${definition[1]}"

      # Check if the definition already exists in the file
      if grep -q "^${input} ${num}$" "$file_name"; then
        echo "The definition already exists in the file!"
      # Validate the format of the definition and numeric value
      elif [[ "$input" =~ $re_string && "$num" =~ $re_number ]]; then
        echo "${input} ${num}" >>"$file_name"
        break
      else
        echo "The definition is incorrect!"
      fi
    fi
  done
}

# Function to print the existing definitions in the file
print_definitions() {
  i=0
  while read -r y; do
    ((i++))
    echo "$i. $y"
  done <"$file_name"
}

# Function to delete a definition from the file
delete_definition() {
  if [ -s "$file_name" ]; then
    echo "Type the line number to delete or '0' to return"
    number_of_lines=$(wc -l <"$file_name")

    # Print the existing definitions
    print_definitions

    while true; do
      read -r -a line_number
      if [ "${line_number[0]}" == "0" ]; then
        break
      elif [ -z "${line_number[0]}" ] || [ "${line_number[0]}" -gt "$number_of_lines" ]; then
        echo -e "Enter a valid line number!"
      else
        # Delete the selected definition
        sed -i "${line_number}d" "$file_name"
        echo "The definition has been deleted!"
        break
      fi
    done
  else
    echo -e "Please add a definition first!\n"
  fi
}

# Function to convert units based on a selected definition and value
convert_units() {
  if [ -s "$file_name" ]; then
    echo "Type the line number to convert units or '0' to return"
    number_of_lines=$(wc -l <"$file_name")

    while true; do
      read -r -a line_number
      if [ "${line_number[0]}" == "0" ]; then
        return
      elif [ -z "${line_number[0]}" ] || [ "${line_number[0]}" -gt "$number_of_lines" ]; then
        echo -e "Enter a valid line number!"
      else
        break
      fi
    done

    echo -e "Enter a value to convert:"
    while true; do
      read -r value_to_convert
      if [[ "$value_to_convert" =~ $re_number ]]; then
        break
      else
        echo "Enter a float or integer value!"
      fi
    done

    # Perform the conversion and print the result to the standard output
    conversion_factor=$(awk "NR==${line_number}" "$file_name" | awk '{print $2}')
    result=$(echo "$conversion_factor * $value_to_convert" | bc)
    echo "Result: $result"

  else
    echo "Please add a definition first!"
  fi
}

# Function to handle user-selected options
handle_option() {
  local option=$1

  case $option in
  0 | 'quit')
    echo "Goodbye!"
    exit 0
    ;;
  1)
    convert_units
    ;;
  2)
    add_definition
    ;;
  3)
    delete_definition
    ;;
  *)
    echo -e "Invalid option!\n"
    ;;
  esac
}

# Main loop to display the menu and process user input
main() {
  while true; do
    menu
    read -r option
    handle_option "$option"
  done
}

# Start the program by calling the main function
main
