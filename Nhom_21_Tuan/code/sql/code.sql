create database tuvansinhvien
go
use tuvansinhvien
go
create table dim_answer(
	ID int primary key,
	Author_ID int,
	Contents nvarchar(max),
	Ques_ID int,
)
go
create table dim_author(
	ID int primary key,
	Stu_ID nvarchar(15),
	FullName nvarchar(100),
	[School] nvarchar(100),
	Email nvarchar(50),
	[School_Year] nvarchar(50),
	[Phone] nvarchar(15),
	[Address] nvarchar(500),
)
go
create table dim_department(
	[Dep_ID] int primary key,
	[Dep_name] nvarchar(100),
	[Note] nvarchar(500),
)
go
create table [dbo].[dim_field](
	[field] int primary key,
	[name] nvarchar(200),
	[Dep_ID] int,

)
go
create table [dbo].[dim_ques](
	ID int primary key,
	[Title] nvarchar(200),
	Contents nvarchar(max),
	[Author_ID] int,
	[Field_ID] int,
	[Dep_ID] int,
	[Total_view] int,
)
go
create table [dbo].[dim_time](
	[ID_time] int primary key,
	[ngay] int,
	thang int,
	nam int,
)
go
create table [dbo].[dim_time_QE](
	ID int primary key,
	[ngay] int,
	thang int,
	nam int,
)
go
create table [dbo].[dim_user](
	[User_ID] int primary key,
	[User_name] nvarchar(50),
	[Email] nvarchar(50),
	[Phone_Number] char(10),
	[Password] nvarchar(100),
	[FullName] nvarchar(100),
	[Dep_ID] int,
	Pos_ID int,
)
go
/*tao bang answer*/
create table fact_answers(
	answer_ID int,
	User_ID int,
	Dep_ID int,
	Time_ID int,
	thang int,
	nam int,
	Dep_name nvarchar(100),
)
/*khoa ngoai fact ans*/
alter table fact_answers add constraint fk_ans foreign key (answer_ID) references dim_answer(ID)
alter table fact_answers add constraint fk_ans1 foreign key (User_ID) references dim_user([User_ID])
alter table fact_answers add constraint fk_ans2 foreign key (Dep_ID) references [dbo].[dim_department]([Dep_ID])
alter table fact_answers add constraint fk_ans3 foreign key (Time_ID) references [dbo].[dim_time]([ID_time]) 
/*inser answer*/
insert into fact_answers(answer_ID,User_ID,Dep_ID,Time_ID,thang,nam,Dep_name)
select ans.ID,u.User_ID,dep.Dep_ID,t.ID_time,t.thang,t.nam,dep.Dep_name
from dim_answer ans join dim_time t on ans.ID=t.ID_time
join dim_user u on ans.Author_ID=u.User_ID
join dim_department dep on u.Dep_ID=dep.Dep_ID
/*update answer*/

/*tao bang fact_ques*/
create table fact_quesion(
	Ques_ID int,
	Author_ID int, 
	Dep_ID int,
	Time_qe_ID int,
	thang int,
	nam int,
	Total_view int,
	Contents nvarchar(max),
	Stu_ID nvarchar(15),
	Dep_name nvarchar(100),

)
go
/*khoa ngoai bang fact_ques*/
alter table fact_quesion add constraint fk_fact_ques foreign key(Ques_ID) references [dbo].[dim_ques]([ID])
alter table fact_quesion add constraint fk_fact_author foreign key(Author_ID) references [dbo].[dim_author]([ID])
alter table fact_quesion add constraint fk_fact_dep foreign key(Dep_ID) references [dbo].[dim_department]([Dep_ID])
alter table fact_quesion add constraint fk_fact_time foreign key(Time_qe_ID) references [dbo].[dim_time_QE]([ID])
/*insert du lieu fact_ques*/
insert into fact_quesion(Ques_ID,Author_ID,Dep_ID,Time_qe_ID,thang,nam,Total_view, Contents,Stu_ID,Dep_name)
select qe.ID,au.ID,dep.Dep_ID,tqe.ID,tqe.thang,tqe.nam,qe.Total_view,qe.Contents,au.Stu_ID,dep.Dep_name
from dim_ques qe join dim_author au on qe.Author_ID=au.ID
join dim_time_QE tqe on qe.ID=tqe.ID
join dim_department dep on qe.Dep_ID=dep.Dep_ID

/*ques unans*/
/*create*/
create table fact_quesunans(
	quesunans_ID int,
	Author_ID int, 
	time_qe_ID int,
	Dep_ID int,
	Dep_name nvarchar(100),
	thang int,
	nam int,
	Total_view int,
)
go

alter table fact_quesunans add constraint fk_fact_quess foreign key(quesunans_ID) references [dbo].[dim_ques]([ID])
alter table fact_quesunans add constraint fk_fact_authors foreign key(Author_ID) references [dbo].[dim_author]([ID])
alter table fact_quesunans add constraint fk_fact_deps foreign key(Dep_ID) references [dbo].[dim_department]([Dep_ID])
alter table fact_quesunans add constraint fk_fact_times foreign key(Time_qe_ID) references [dbo].[dim_time_QE]([ID])

insert into fact_quesunans(quesunans_ID,Author_ID,time_qe_ID,Dep_ID,Dep_name,thang,nam,Total_view)
select qe.ID, au.ID,tqe.ID,dep.Dep_ID,dep.Dep_name,tqe.thang,tqe.nam,qe.Total_view
from dim_ques qe join dim_author au on qe.Author_ID=au.ID
join dim_time_QE tqe on qe.ID=tqe.ID
join dim_department dep on qe.Dep_ID=dep.Dep_ID
left join dim_answer ans on qe.ID=ans.Ques_ID
where ans.Ques_ID is null