trigger AccountTrigger on Account (before update) {//in after update we cant update current record
	Test2.triggerAfterAccountsUpdate(Trigger.newMap);
}