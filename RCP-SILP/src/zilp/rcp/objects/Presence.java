package zilp.rcp.objects;

/**
 * This class represents Presence node
 * 
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class Presence {

	private String entry; // wejscie
	private String exit; // wyjscie
	private String presenceTime; // czasObecnosci
	private String incomplette; // niekompletna
	private String typeExit; // wyjscieSluzbowe, wyjsciePrywatne,
								// wyjscieSpecjalne

	public Presence() {
	}

	public void setEntry(final String entry) {
		this.entry = entry;
	}

	public String getEntry() {
		return entry;
	}

	public void setExit(final String exit) {
		this.exit = exit;
	}

	public String getExit() {
		return exit;
	}

	public void setPresenceTime(final String presenceTime) {
		this.presenceTime = presenceTime;
	}

	public String getPresenceTime() {
		return presenceTime;
	}

	public void setIncomplette(final String incomplette) {
		this.incomplette = incomplette;
	}

	public String getIncomplette() {
		return incomplette;
	}

	public String getTypeExit() {
		return typeExit;
	}

	public void setTypeExit(final String typeExit) {
		this.typeExit = typeExit;
	}
}