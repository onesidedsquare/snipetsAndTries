def is_palindrome(word):
    return word == word[::-1]

def find_palindromes_in_file(file_path):
    palindromes = []
    with open(file_path, 'r') as file:
        for line in file:
            words = line.strip().split()
            for word in words:
                if is_palindrome(word):
                    palindromes.append(word)
    return palindromes

file_path = "sample.txt"  # Update with the path to your file
palindromes = find_palindromes_in_file(file_path)

for palindrome in palindromes:
    print(palindrome)
