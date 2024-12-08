public with sharing class OverdueReminderScheduler implements Schedulable {
    // Existing execute method remains the same
    public void execute(SchedulableContext sc) {
        try {
            // Log execution time
            System.debug('Overdue Reminder Job Started at: ' + System.now());
            
            // Send reminders
            OverdueReminderService.sendOverdueReminders();
            
            // Optional: Log completion
            System.debug('Overdue Reminder Job Completed Successfully');
        } catch (Exception e) {
            // Log any errors
            System.debug('Error in Overdue Reminder Scheduler: ' + e.getMessage());
        }
    }

    // New method to schedule the job
    public static void scheduleJob() {
        // Remove any existing scheduled jobs with the same name to prevent duplicates
        List<CronTrigger> existingJobs = [
            SELECT Id 
            FROM CronTrigger 
            WHERE CronJobDetail.Name = 'Daily Overdue Reminders'
        ];
        
        for (CronTrigger job : existingJobs) {
            System.abortJob(job.Id);
        }
        
        // Schedule the new job
        System.schedule(
            'Daily Overdue Reminders', 
            '0 0 9 * * ?',  // Runs at 9:00 AM daily
            new OverdueReminderScheduler()
        );
    }
}