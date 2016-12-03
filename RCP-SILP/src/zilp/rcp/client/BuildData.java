package zilp.rcp.client;


public class BuildData {
	String day;
	String presence;
		
	public BuildData(final String day, final String presence) {
		this.day = day;
		this.presence = presence;
	}
	
	public String getDay() {
		return day;
	}
	
	public String getPresence() {
		return presence;
	}
}
