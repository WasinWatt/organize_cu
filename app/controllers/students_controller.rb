class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_personnel

  # GET /students
  # GET /students.json
  def index
    @students = Student.all
    respond_to do |format|
			format.html { render :index }
			format.json { render json: Oj.dump(@students) }
		end
  end

  # GET /students/1
  # GET /students/1.json
  def show
    #Get student
    @student = Student.find(params[:id])

    #Academic Info
    @gpa = Gpa.where(student_id:@student.id)
    @gpax = Gpa.find_by_sql("SELECT SUM(credit*gpa)/SUM(credit) as gpax FROM gpas WHERE student_id = \'"+params[:id]+"\'")

    #Group Info
    @in_group = BelongTo.where(student_id: @student.id)

    puts "NO. OF GROUP: " + @in_group.count.to_s

    #Leave Info    
    @personal_leave_arr = Array.new
    @sick_leave_arr = Array.new

    @in_group.each do |group|
      @leave = Leave.where(group_id: group.id).order(start_date: :desc)
      puts "NO. OF LEAVING: " + @leave.count.to_s
      @leave.each do |leave|
        personal_leave = PersonalLeave.where(leave_id:leave.id).first
        sick_leave = SickLeave.where(leave_id:leave.id).first
        puts "LEAVING TYPE: "
        puts personal_leave
        puts sick_leave
        puts "END LEAVING TYPE"
        if !personal_leave.nil?   
          @personal_leave_arr.push([leave, personal_leave]) 
        else 
          @sick_leave_arr.push([leave, sick_leave])
        end
      end
    end

    respond_to do |format|
      format.html { render :show }
      format.json { render json: Oj.dump(@student) }
    end
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url, notice: 'Student was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.fetch(:student, {})
    end
end
