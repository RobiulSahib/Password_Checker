# 🔐 EMU8086 Password Strength Checker

This project is a simple password strength checker written in **8086 Assembly Language** using **EMU8086**. It evaluates the strength of a password based on multiple rules and gives it a score.

---

## ✅ Features

### Feature 3: Pattern Detection
- Detects **sequential characters** like `123` or `abc` and updates a variable (`sequence1`) to 1.
- Detects **repeated characters** like `aaa` and updates a variable (`sequence2`) to 1.
- These sequences are only detected once, no matter how many times they appear.

### Feature 4: Scoring System (6 Rules, Max 10 Points)
The program awards points based on these conditions:
| Condition                             | Points |
|--------------------------------------|--------|
| Password length ≥ 12                 |   +2   |
| Password length between 9 and 11     |   +1   |
| 3 or more digits                     |   +2   |
| 1 or 2 digits                        |   +1   |
| Contains both uppercase & lowercase |   +1   |
| 3 or more special characters         |   +2   |
| 1 or 2 special characters            |   +1   |

The total score is stored in a variable called `passwordstr`.

---

## 💻 How It Works

- User inputs a password.
- The program counts:
  - Total characters
  - Digits
  - Uppercase and lowercase letters
  - Special characters
- It checks for:
  - Sequences (e.g., `abc`, `123`)
  - Repetitions (e.g., `aaa`)
- Applies the 6-point scoring rules and displays the final strength score.

---

## ▶️ How to Run

### 1. Open EMU8086
- Open the `.asm` file in EMU8086.
- Or create a new file, paste the code, and save as `password_checker.asm`.

### 2. Compile and Run
- Click **"Compile and Run"** (or press `F5`).
- Enter a password when prompted.
- See the strength score and feedback.

---

## 🛠 Built With

- **EMU8086** – Assembly language emulator and editor
- **8086 Assembly Language** – Low-level programming for x86 CPUs

---

## 📌 Notes

- The scoring logic and sequence detection are implemented using simple loops and conditions.
- The code is beginner-friendly and easy to understand for educational purposes.

---

## 🧑‍🎓 Author

This code was written as a part of an educational project to demonstrate pattern detection and password strength evaluation in assembly language.

