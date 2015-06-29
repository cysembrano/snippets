using System;
using System.Collections.Generic;
using System.Configuration;
using log4net;
using log4net.Config;
using log4net.Core;
using log4net.Repository;
using log4net.Appender;
using log4net.Plugin;

namespace Flow.WebPortal.Logging
{
    public class Log4NetManager
    {
        #region Static Region

        public static bool Configured { get; private set; }
        public static Log4NetManager Instance { get; private set; }
        public static bool LoggingEnabled { get; private set; }

        static Log4NetManager()
        {
            Log4NetManager.Instance = new Log4NetManager();
            Log4NetManager.Configured = false;
            
            string key = String.Format("{0}.LoggingEnabled", typeof(Log4NetManager).FullName);
            string value = ConfigurationManager.AppSettings[key];
            bool result = false;

            if (Boolean.TryParse(value, out result))
                Log4NetManager.LoggingEnabled = result;
            else
                // Default to true, as this entry in the AppSettings.config will be missing on most
                // upgrades.
                Log4NetManager.LoggingEnabled = true;
        }

        private static void Configure()
        {
            XmlConfigurator.Configure();
            Log4NetManager.Configured = true;
        }

        public static void EnsureConfigured()
        {
            if (!Log4NetManager.LoggingEnabled)
                return;

            if (!Log4NetManager.Configured)
                Log4NetManager.Configure();
        }

        #endregion

        #region Instance Region

        private Dictionary<Type, ILog> Logs { get; set; }

        public Log4NetManager()
        {
            this.Logs = new Dictionary<Type, ILog>();
        }

        private void EnsureLog(Type type)
        {
            if (!this.Logs.ContainsKey(type))
                this.Logs.Add(type, LogManager.GetLogger(type));
        }

        public ILog GetLog(Type type)
        {
            if (!Log4NetManager.LoggingEnabled)
                return null;

            this.EnsureLog(type);
            return this.Logs[type];
        }

        public void Error(Type type, object message)
        {
            if (!Log4NetManager.LoggingEnabled)
                return;

            this.EnsureLog(type);
            this.Logs[type].Error(message);
        }

        public void Warn(Type type, object message)
        {
            if (!Log4NetManager.LoggingEnabled)
                return;

            this.EnsureLog(type);
            this.Logs[type].Warn(message);
        }

        public void Info(Type type, object message)
        {
            if (!Log4NetManager.LoggingEnabled)
                return;

            this.EnsureLog(type);
            this.Logs[type].Info(message);
        }

        public void Error(Type type, object message, Exception exception)
        {
            if (!Log4NetManager.LoggingEnabled)
                return;

            this.EnsureLog(type);
            this.Logs[type].Error(message, exception);
        }

        public void ErrorFormat(Type type, string format, params object[] args)
        {
            if (!Log4NetManager.LoggingEnabled)
                return;

            this.EnsureLog(type);
            this.Logs[type].ErrorFormat(format, args);
        }

        public void Debug(Type type, object message)
        {
            if (!Log4NetManager.LoggingEnabled)
                return;

            this.EnsureLog(type);
            this.Logs[type].Debug(message);
        }

        public void Debug(Type type, object message, Exception exception)
        {
            if (!Log4NetManager.LoggingEnabled)
                return;

            this.EnsureLog(type);
            this.Logs[type].Debug(message, exception);
        }

        #endregion
    }

}
