trigger ContactTrigger on Contact (before update) {
	// 
	for (Contact c : Trigger.new) {
		Contact pc = Trigger.oldMap.get(c.Id);
		if (c.LastName != pc.LastName) {
			// Lastname changed
			if (c.Prev_Lastnames__c == null) c.Prev_Lastnames__c = pc.LastName;
			else if (!(c.Prev_lastnames__c + ',').contains(pc.LastName + ',')) {
				String newPrev = pc.LastName + ', ' + c.Prev_Lastnames__c;
				Integer newLen = newPrev.length();
				if (newLen > 255) {
					String[] lastnames = c.Prev_Lastnames__c.split(', ');
					lastnames.add(0, pc.LastName);
					Integer ubound = lastnames.size() - 1;
					for (Integer i = ubound; i >= 0; i--) {
						newLen = newLen - lastnames[i].length() - 2;
						lastnames.remove(i);

						if (newLen <= 255) break;
					}

					newPrev = String.join(lastnames, ', ');
				}
				c.Prev_Lastnames__c = newPrev;
			}
		}
	}
}