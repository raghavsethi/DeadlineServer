function printLocalDate(dateInMillis)
{
	var now = new Date(dateInMillis);

	var month = now.getMonth()
	
	var m_names = new Array("January", "February", "March", 
	"April", "May", "June", "July", "August", "September", 
	"October", "November", "December");
	
	var curr_date = now.getDate();
	var sup = "";
	if (curr_date == 1 || curr_date == 21 || curr_date ==31)
	   {
	   sup = "st";
	   }
	else if (curr_date == 2 || curr_date == 22)
	   {
	   sup = "nd";
	   }
	else if (curr_date == 3 || curr_date == 23)
	   {
	   sup = "rd";
	   }
	else
	   {
	   sup = "th";
	   }

	return (m_names[month] + " " + curr_date)						
}

function printLocalDay(dateInMillis)
{
	var now = new Date(dateInMillis);
	
	var d_names = new Array("Sunday", "Monday", "Tuesday",
	"Wednesday", "Thursday", "Friday", "Saturday");

	return (d_names[now.getDay()])						
}

function printLocalTime(dateInMillis)
{
	if(!dateInMillis)
		return "all day";
	var now = new Date(dateInMillis);
	var day = now.getDate();
	var month = now.getMonth();
	var year = now.getFullYear();
	var hours = now.getHours();
	var minutes = now.getMinutes();
	var suffix = "am";
	if (hours >= 12) {
	suffix = "pm";
	hours = hours - 12;
	}
	if (hours == 0) {
	hours = 12;
	}
	if (minutes < 10)
	minutes = "0" + minutes

	return (hours + ":" + minutes + " " + suffix)						
}

function pad(number, length){
    var str = "" + number
    while (str.length < length) {
        str = '0'+str
    }
    return str
}
