keep id s1 s41 a2 a301 a4 a4a a7a a7b a7c a8a a58 a68a a69 a72 a59c a59e
gen is_urban = (s1 == 1)
gen is_male = (a2 == 1)
gen age = 2015 - a301

gen school = 0
replace school = 3 if a7a == 2
replace school = 6 if a7a == 3
replace school = 9 if a7a == 4
replace school = 12 if a7a >=5 & a7a <= 8
replace school = 15 if a7a >=9 & a7a <= 10
replace school = 16 if a7a >=11 & a7a <= 12
replace school = 19 if a7a == 13

gen is_rare_folk = (a4 == 1)

gen exp = age - 6 - school
gen sq_exp = exp * exp

gen couple_school = 0 
replace couple_school = 3 if a72 == 2
replace couple_school = 6 if a72 == 3
replace couple_school = 9 if a72 == 4
replace couple_school = 12 if a72 >=5 & a72 <= 8
replace couple_school = 15 if a72 >=9 & a72 <= 10
replace couple_school = 16 if a72 >=11 & a72 <= 12
replace couple_school = 19 if a72 == 13

gen ln_yi = ln(a8a)
gen children_count = a68a
gen is_working = (a58 <= 3)

gen is_wealthy = 0
replace is_wealthy = 1 if s41 == 1
replace is_wealthy = 1 if s41 == 4
replace is_wealthy = 1 if s41 == 19
replace is_wealthy = 1 if s41 == 15
replace is_wealthy = 1 if s41 == 12
replace is_wealthy = 1 if s41 == 7
replace is_wealthy = 1 if s41 == 24
replace is_wealthy = 1 if s41 == 10
replace is_wealthy = 1 if s41 == 27
replace is_wealthy = 1 if s41 == 3
replace is_wealthy = 1 if s41 == 22
replace is_wealthy = 1 if s41 == 28
replace is_wealthy = 1 if s41 == 21
replace is_wealthy = 1 if s41 == 9

//匹配一个虚拟配偶
gen school_diff = couple_school - school
replace school_diff = 0 if a72 < 0 | a72 == . | a72 == 14
egen sd_diff = sd(school_diff ) if !(a72 < 0 | a72 == . | a72 == 14)
egen mean_diff = mean(school_diff ) if !(a72 < 0 | a72== . | a72 ==14)
replace school_diff = rnormal(0, 3.812463) if (a72 < 0 | a72 ==. | a72 ==14)
replace couple_school = school + school_diff if (a72<0|a72==.|a72==14)


// 删除未工作样本
drop if is_working == 0
replace children_count = 0 if children_count == .
// 清理没有收入的
drop if ln_yi == 0 | ln_yi == .
// 清理非劳动力年龄的
drop if age < 16 | age > 60
// 清理没有教育记录的数据
drop if a7a < 0 | a7a == . | a7a == 14

// 回归 & IV回归
reg ln_yi school exp sq_exp is_male is_urban is_wealthy children_count


//清理没有配偶教育记录的数据
//drop if a72 < 0 | a72 == . | a72 == 14

ivreg ln_yi (school = couple_school) exp sq_exp is_male  is_urban is_wealthy children_count


// 生成分阶段哑变量
gen finish_primary = (school >= 6)
gen finish_middle = (school >= 9)
gen finish_high = (school >= 12)
gen finish_university = (school >= 15)
gen finish_graduate = (school >= 19)

// 分阶段回归
reg ln_yi exp sq_exp is_male is_urban children_count is_wealthy finish_primary finish_middle finish_high finish_university finish_graduate

// 分位数回归
sqreg ln_yi exp sq_exp is_male is_urban children_count is_wealthy finish_primary finish_middle finish_high finish_university finish_graduate, quantile(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9)


sqreg ln_yi school exp sq_exp is_male is_urban is_wealthy children_count, quantile(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9)







