USE msdb;
GO

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Job_Waitlist_QuetDinhKy')
    EXEC msdb.dbo.sp_delete_job @job_name = N'Job_Waitlist_QuetDinhKy';
GO

EXEC msdb.dbo.sp_add_job
    @job_name = N'Job_Waitlist_QuetDinhKy',
    @enabled = 1,
    @description = N'Quet dinh ky bang DANHSACHCHO va khop khach voi phong vua trong.';
GO

EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Job_Waitlist_QuetDinhKy',
    @step_name = N'Buoc_QuetWaitlist',
    @subsystem = N'TSQL',
    @command = N'EXEC QL_KhachSan.dbo.sp_Waitlist_QuetDinhKy;',
    @database_name = N'QL_KhachSan';
GO

EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'LichQuet_Waitlist_15Phut',
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 4,
    @freq_subday_interval = 15;
GO

EXEC msdb.dbo.sp_attach_schedule
    @job_name = N'Job_Waitlist_QuetDinhKy',
    @schedule_name = N'LichQuet_Waitlist_15Phut';
GO

EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Job_Waitlist_QuetDinhKy',
    @server_name = @@SERVERNAME;
GO
