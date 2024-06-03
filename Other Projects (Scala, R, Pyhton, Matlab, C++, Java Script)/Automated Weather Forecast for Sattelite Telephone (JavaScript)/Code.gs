// Running this file creates a 10minutes-trigger and the routine which is run (every 10 minutes).
// The main routine is hidden in textBody.gs though.

function setEmailReplyTrigger () {
  markOldEmailThreadsAsReplied();
  ScriptApp
  .newTrigger('sendRepliesToEmails')
  .timeBased()
  .everyMinutes(1)
  .create();
}


function markOldEmailThreadsAsReplied() {
  GmailApp.createLabel("replied");
  const allInboxEmailThreads = GmailApp.search(`is:inbox -label:replied`);
  allInboxEmailThreads.forEach((emailThread) => {
    addRepliedLabel(emailThread);
  });
}

function sendRepliesToEmails() {
  const notRepliedEmailThreads = GmailApp.search(`is:inbox -label:replied`);
  for(i = 0; i < notRepliedEmailThreads.length; i++) {
    const emailThread = notRepliedEmailThreads[i];
    sendReplyTo(emailThread);
    addRepliedLabel(emailThread);
  }
}

function sendReplyTo(emailThread) {
  Logger.log("Hier");
  emailThread.reply(textBody());
  Logger.log("Da");
}

function addRepliedLabel(emailThread) {
  const repliedLabel = GmailApp.getUserLabelByName("replied");
  emailThread.addLabel(repliedLabel);
}

