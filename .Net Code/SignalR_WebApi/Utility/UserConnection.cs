using System.Collections.Generic;

namespace Web.Api.Hubs.Utility
{
    public class UserConnection
    {
        public UserConnection()
        {
            Connections = new List<Connection>();
        }
        public IList<Connection> Connections { get; set; }
    }

    public class Connection
    {
        public Connection(string hub, string connection)
        {
            Hub = hub;
            ConnectionId = connection;
        }
        public string Hub { get; set; }
        public string ConnectionId { get; set; }
    }
}
