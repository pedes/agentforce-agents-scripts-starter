public with sharing class PersonalizedGuestExperiences {

    @InvocableMethod(
        Label='Get Session Recommendations'
        Description='Suggests sessions happening today based on guest interests.'
    )
    public static List<Response> getSessions(List<Request> requests) {
        List<Response> responses = new List<Response>();
        
        // 1. Collect all Interests from all Contacts to minimize queries (Bulkification)
        Set<String> allInterests = new Set<String>();
        for (Request req : requests) {
            if (req.myContact != null) {
                if (req.myContact.Interest1__c != null) allInterests.add(req.myContact.Interest1__c);
                if (req.myContact.Interest2__c != null) allInterests.add(req.myContact.Interest2__c);
                if (req.myContact.Interest3__c != null) allInterests.add(req.myContact.Interest3__c);
            }
        }

        // 2. Query ALL potentially relevant sessions for TODAY
        // We query sessions matching ANY interest in the batch.
        List<Session__c> potentialSessions = new List<Session__c>();
        try {
            potentialSessions = [
                SELECT Id, 
                       Experience_Name__c, 
                       Date__c, 
                       Start_Time__c, 
                       Duration_Hours__c, 
                       Location__c,
                       Experience__r.Type__c  // Needed to match back to contact interests
                FROM Session__c 
                WHERE Experience__r.Type__c IN :allInterests
                AND Date__c = TODAY
                AND Is_Canceled__c = false
                WITH SECURITY_ENFORCED
                ORDER BY Start_Time__c ASC
            ];
        } catch (Exception e) {
            System.debug('Error querying sessions: ' + e.getMessage());
        }

        // 3. Organize Sessions by "Type" for easy lookup
        Map<String, List<Session__c>> sessionsByType = new Map<String, List<Session__c>>();
        for (Session__c sess : potentialSessions) {
            String type = sess.Experience__r.Type__c;
            if (type != null) {
                if (!sessionsByType.containsKey(type)) {
                    sessionsByType.put(type, new List<Session__c>());
                }
                sessionsByType.get(type).add(sess);
            }
        }

        // 4. Build Response for each Contact
        for (Request req : requests) {
            Response res = new Response();
            List<Session__c> matchingSessions = new List<Session__c>();
            
            if (req.myContact != null) {
                // Check Interest 1
                if (req.myContact.Interest1__c != null && sessionsByType.containsKey(req.myContact.Interest1__c)) {
                    matchingSessions.addAll(sessionsByType.get(req.myContact.Interest1__c));
                }
                // Check Interest 2
                if (req.myContact.Interest2__c != null && sessionsByType.containsKey(req.myContact.Interest2__c)) {
                    matchingSessions.addAll(sessionsByType.get(req.myContact.Interest2__c));
                }
                // Check Interest 3
                if (req.myContact.Interest3__c != null && sessionsByType.containsKey(req.myContact.Interest3__c)) {
                    matchingSessions.addAll(sessionsByType.get(req.myContact.Interest3__c));
                }
            }

            // Deduplicate (in case two interests map to the same session)
            Map<Id, Session__c> uniqueSessions = new Map<Id, Session__c>(matchingSessions);
            List<Session__c> finalSessionList = uniqueSessions.values();
            
            // Format for LLM
            if (finalSessionList.isEmpty()) {
                res.Prompt = 'There are no sessions today matching the guest\'s interests.';
            } else {
                res.Prompt = formatSessionsForLLM(finalSessionList);
            }
            
            responses.add(res);
        }

        return responses;
    }

    // Helper: Formats the output for the Prompt Builder
    private static String formatSessionsForLLM(List<Session__c> sessions) {
        String output = 'Recommended Sessions for Today:\n';
        Integer count = 0;
        
        for (Session__c sess : sessions) {
            if (count >= 10) break; // Respect the LIMIT 10 requirement per guest
            
            output += '- ' + sess.Experience_Name__c;
            if (sess.Start_Time__c != null) {
                // Formatting time cleanly. 
                // DateTime.newInstance is used here to access format() easily for Time fields
                DateTime dt = DateTime.newInstance(Date.today(), sess.Start_Time__c);
                output += ' at ' + dt.format('h:mm a'); 
            }
            if (sess.Duration_Hours__c != null) {
                output += ' (' + sess.Duration_Hours__c + ' hrs)';
            }
            if (String.isNotBlank(sess.Location__c)) {
                output += ', Location: ' + sess.Location__c;
            }
            output += '\n';
            count++;
        }
        return output;
    }

    public class Request {
        @InvocableVariable(required=true)
        public Contact myContact;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}
