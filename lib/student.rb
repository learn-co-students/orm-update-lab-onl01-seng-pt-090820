require_relative "../config/environment.rb"

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT)    
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

    else
      sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
  end

  def self.create(name, grade)
    student = self.new(name, grade).save
  end

  def self.new_from_db(student_array)
    student = self.new(student_array[0], student_array[1], student_array[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE students.name = ?
    SQL
    student = DB[:conn].execute(sql, name)
    new_student = new_from_db(student[0])
    new_student
  end
  
  def update
    sql = <<-SQL
      UPDATE students 
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
