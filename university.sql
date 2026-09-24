--CREATE DATABASE university_db

CREATE TABLE faculties (
    faculty_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    dean_name VARCHAR(100) NOT NULL,
    founded_year INT CHECK (founded_year > 1900 AND founded_year <= EXTRACT(YEAR FROM CURRENT_DATE))
);

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    head_name VARCHAR(100) NOT NULL,
    faculty_id INT NOT NULL,
    FOREIGN KEY (faculty_id) REFERENCES faculties(faculty_id) ON DELETE CASCADE
);

CREATE TABLE student_groups (
    group_id SERIAL PRIMARY KEY,
    group_number VARCHAR(20) NOT NULL UNIQUE,
    course_year INT CHECK (course_year BETWEEN 1 AND 6),
    specialty VARCHAR(150) NOT NULL,
    curator_name VARCHAR(100)
);

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE CHECK (birth_date < CURRENT_DATE - INTERVAL '15 years'),
    group_id INT NOT NULL,
    enrollment_year INT NOT NULL,
    status VARCHAR(50) DEFAULT 'учится' CHECK (status IN ('учится', 'отчислен', 'выпускник', 'академ')),
    FOREIGN KEY (group_id) REFERENCES student_groups(group_id) ON DELETE RESTRICT
);

CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    degree VARCHAR(100),
    position VARCHAR(100) NOT NULL,
    experience_years INT CHECK (experience_years >= 0),
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    credits INT CHECK (credits > 0),
    semester INT CHECK (semester > 0),
    teacher_id INT,
    department_id INT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade INT CHECK (grade BETWEEN 2 AND 5),
    exam_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE (student_id, course_id)
);

CREATE TABLE schedules (
    schedule_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    day_of_week INT CHECK (day_of_week BETWEEN 1 AND 7),
    class_time TIME NOT NULL,
    room VARCHAR(20) NOT NULL,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
);

CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    schedule_id INT NOT NULL,
    class_date DATE NOT NULL,
    is_present BOOLEAN NOT NULL DEFAULT FALSE,
    skip_reason VARCHAR(255),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id) ON DELETE CASCADE
);

CREATE TABLE scholarships (
    scholarship_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    type VARCHAR(100) NOT NULL CHECK (type IN ('Академическая', 'Социальная', 'Повышенная', 'Именная')),
    amount DECIMAL(10, 2) CHECK (amount > 0),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

INSERT INTO faculties (name, dean_name, founded_year) VALUES
('Физико-технический факультет', 'Иванов И.И.', 1970),
('Факультет компьютерных технологий', 'Петров П.П.', 1995),
('Экономический факультет', 'Сидоров С.С.', 1985),
('Юридический факультет', 'Алексеев А.А.', 1990),
('Филологический факультет', 'Смирнова С.В.', 1975);

INSERT INTO departments (name, head_name, faculty_id) VALUES
('Кафедра теоретической физики', 'Морозов М.М.', 1),
('Кафедра информационных технологий', 'Васильев В.В.', 2),
('Кафедра прикладной математики', 'Кузнецов К.К.', 2),
('Кафедра гражданского права', 'Николаев Н.Н.', 4),
('Кафедра экономики', 'Борисов Б.Б.', 3);

INSERT INTO student_groups (group_number, course_year, specialty, curator_name) VALUES
('ФТ-101', 1, 'Радиофизика', 'Морозов М.М.'),
('ИТ-201', 2, 'Программная инженерия', 'Васильев В.В.'),
('ЮР-301', 3, 'Юриспруденция', 'Николаев Н.Н.'),
('ЭК-401', 4, 'Экономика', 'Борисов Б.Б.'),
('ФТ-202', 2, 'Физика', 'Иванов И.И.');

INSERT INTO students (full_name, birth_date, group_id, enrollment_year, status) VALUES
('Алексеев Роман Игоревич', '2005-04-12', 1, 2023, 'учится'),
('Смирнова Анна Сергеевна', '2004-11-23', 2, 2022, 'учится'),
('Козлов Дмитрий Владимирович', '2003-08-15', 3, 2021, 'учится'),
('Ильина Мария Александровна', '2002-02-10', 4, 2020, 'отчислен'),
('Соколов Максим Андреевич', '2004-05-30', 5, 2022, 'учится');

INSERT INTO teachers (full_name, degree, position, experience_years, department_id) VALUES
('Лебедев Сергей Петрович', 'Кандидат физ.-мат. наук', 'Доцент', 15, 1),
('Крылова Елена Викторовна', 'Доктор техн. наук', 'Профессор', 25, 2),
('Попов Александр Дмитриевич', 'Кандидат экон. наук', 'Старший преподаватель', 8, 5),
('Макарова Татьяна Ивановна', 'Доктор юрид. наук', 'Профессор', 30, 4),
('Тихонов Игорь Юрьевич', 'Без степени', 'Ассистент', 2, 3);

INSERT INTO courses (name, credits, semester, teacher_id, department_id) VALUES
('Основы программирования на Java', 4, 1, 2, 2),
('Алгоритмы и структуры данных', 5, 2, 2, 2),
('Физика', 6, 1, 1, 1),
('Гражданское право', 5, 5, 4, 4),
('Экономика', 4, 7, 3, 5);

INSERT INTO enrollments (student_id, course_id, grade, exam_date) VALUES
(2, 1, 5, '2023-01-15'),
(2, 2, 4, '2023-06-20'),
(1, 3, 2, '2023-01-18'),
(3, 4, 4, '2023-01-20'),
(5, 3, 3, '2023-01-18');

INSERT INTO schedules (course_id, day_of_week, class_time, room) VALUES
(1, 1, '09:00:00', 'Ауд. 201'),
(2, 2, '10:40:00', 'Ауд. 202'),
(3, 3, '13:00:00', 'Ауд. 315'),
(4, 4, '09:00:00', 'Ауд. 410'),
(5, 5, '15:00:00', 'Ауд. 105');

INSERT INTO attendance (student_id, schedule_id, class_date, is_present, skip_reason) VALUES
(2, 1, '2023-09-04', TRUE, NULL),
(2, 1, '2023-09-11', FALSE, 'Болезнь'),
(1, 3, '2023-09-06', TRUE, NULL),
(1, 3, '2023-09-13', FALSE, 'Прогул'),
(3, 4, '2023-09-07', TRUE, NULL);

INSERT INTO scholarships (student_id, type, amount, period_start, period_end) VALUES
(2, 'Академическая', 3500.00, '2023-09-01', '2024-01-31'),
(3, 'Социальная', 4000.00, '2023-09-01', '2024-01-31'),
(5, 'Академическая', 3500.00, '2023-09-01', '2024-01-31'),
(1, 'Социальная', 4000.00, '2023-09-01', '2024-01-31'),
(2, 'Повышенная', 6000.00, '2023-09-01', '2024-01-31');

--Изменение данных: переводим студента в академ, если у него есть двойка
UPDATE students 
SET status = 'академ' 
WHERE student_id IN (
    SELECT student_id FROM enrollments WHERE grade = 2
);

-- Удаление данных: удаляем посещаемость с неуважительной причиной или пустой старше определенной даты
DELETE FROM attendance 
WHERE (skip_reason = 'Прогул' OR skip_reason IS NULL) AND class_date < '2023-09-10';

--Очистка данных
--TRUNCATE TABLE scholarships RESTART IDENTITY CASCADE;

--Запрос 1: Средний балл каждого студента
SELECT 
    s.full_name AS Студент,
    g.group_number AS Группа,
    ROUND(AVG(e.grade), 2) AS Средний_балл,
    COUNT(e.course_id) AS Сдано_курсов
FROM students s
JOIN student_groups g ON s.group_id = g.group_id
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.full_name, g.group_number
ORDER BY Средний_балл DESC NULLS LAST;

--Запрос 2: Преподаватели без курсов
SELECT 
    t.full_name AS Преподаватель,
    t.position AS Должность,
    d.name AS Кафедра
FROM teachers t
JOIN departments d ON t.department_id = d.department_id
LEFT JOIN courses c ON t.teacher_id = c.teacher_id
WHERE c.course_id IS NULL;

--Запрос 3: Студенты-должники
SELECT 
    s.full_name AS Должник,
    g.group_number AS Группа,
    STRING_AGG(c.name, ', ') AS Курсы_с_задолженностью
FROM students s
JOIN student_groups g ON s.group_id = g.group_id
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE e.grade = 2
GROUP BY s.student_id, s.full_name, g.group_number;

--Запрос 4: Средний балл по каждому курсу и преподавателю
SELECT 
    c.name AS Курс,
    t.full_name AS Преподаватель,
    ROUND(AVG(e.grade), 2) AS Средний_балл,
    COUNT(e.student_id) AS Количество_студентов
FROM courses c
JOIN teachers t ON c.teacher_id = t.teacher_id
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.name, t.full_name
ORDER BY Курс;

--Запрос 5: Посещаемость по студентам
SELECT 
    s.full_name AS Студент,
    COUNT(a.attendance_id) AS Всего_занятий,
    SUM(CASE WHEN a.is_present = FALSE THEN 1 ELSE 0 END) AS Пропусков,
    ROUND((SUM(CASE WHEN a.is_present = TRUE THEN 1 ELSE 0 END)::numeric / COUNT(a.attendance_id)) * 100, 1) AS Процент_посещаемости
FROM students s
JOIN attendance a ON s.student_id = a.student_id
GROUP BY s.student_id, s.full_name
ORDER BY Процент_посещаемости DESC;