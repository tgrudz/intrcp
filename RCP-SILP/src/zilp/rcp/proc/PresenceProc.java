package zilp.rcp.proc;

import java.util.ArrayList;
import java.util.List;

import org.jdom.Element;

import zilp.rcp.objects.Presence;

/**
 * This class build list of Presence objects object from list of xml elements
 * 
 * @author Jakub Pawlowski
 * @version 1.0
 **/
public class PresenceProc {

	private static final int START_INDEX = 4;
	private static final String emptyString = "";
	private static final String SLUZBOWE = "S";
	private static final String PRYWATNE = "P";
	private static final String SPECJALNE = "X";
	private static final String EMPTY_STRING = "";

	Presence pres;
	List<Presence> presList;

	public PresenceProc() {
		presList = new ArrayList<Presence>();
	}

	public List<Presence> precessPresences(List<Element> presencesList) {

		for (final Element elPres : presencesList) {

			pres = new Presence();

			final String entry = getFieldEntryOrExit(elPres.getAttributeValue("wejscie"));
			final String exit = getFieldEntryOrExit(elPres.getAttributeValue("wyjscie"));
			final String presenceTime = elPres.getAttributeValue("czasObecnosci");
			final String incomplette = elPres.getAttributeValue("niekompletna");
			final String typeExit = getTypeExit(elPres, incomplette);

			pres.setEntry(entry);
			pres.setExit(exit);
			pres.setPresenceTime(presenceTime);
			pres.setIncomplette(incomplette);
			pres.setTypeExit(typeExit);

			presList.add(pres);
		}
		return presList;
	}

	private String getTypeExit(final Element elPres, final String incomplette) {
		if (returnEmptyIfNull(elPres.getAttributeValue("wyjscieSluzbowe")).equals("T")) {
			return SLUZBOWE;
		}
		if (returnEmptyIfNull(elPres.getAttributeValue("wyjsciePrywatne")).equals("T")) {
			return PRYWATNE;
		}
		if (returnEmptyIfNull(elPres.getAttributeValue("wyjscieSpecjalne")).equals("T")) {
			return SPECJALNE;
		}
		return EMPTY_STRING;
	}

	private String getFieldEntryOrExit(final String field) {
		return (field == null || field.length() < START_INDEX + 1) ? emptyString : field.substring(START_INDEX);
	}
 
	private String returnEmptyIfNull(final String string) {
		return (string == null) ? EMPTY_STRING : string;
	}
}