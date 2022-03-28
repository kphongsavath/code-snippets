using Web.Api.Hubs.Interfaces;
using System.Collections.Concurrent;
using System.Linq;

namespace Web.Api.Hubs.Utility
{
    public class UserManager : IUserManager
    {
        public UserManager() { UserConnections = new ConcurrentDictionary<string, UserConnection>(); }
        public ConcurrentDictionary<string, UserConnection> UserConnections { get; set; }

        public void AddConnection(string userName, Connection connection)
        {
            if (UserConnections.ContainsKey(userName))
            {
                if (connection != null)
                {
                    var nullConnects = from c in UserConnections[userName].Connections
                                       where c == null
                                       select UserConnections[userName].Connections.IndexOf(c);
                    foreach (var index in nullConnects)
                    {
                        UserConnections[userName].Connections.RemoveAt(index);
                    }
                    var con = UserConnections[userName].Connections.ToList().FirstOrDefault(c => c.Hub == connection.Hub && c.ConnectionId == connection.ConnectionId);
                    if (con == null)
                    {
                        UserConnections[userName].Connections.Add(connection);
                    }

                }
            }
            else
            {
                SetUser(userName, connection);
            }
        }

        public void RemoveUser(string userName)
        {
            if (UserConnections.ContainsKey(userName))
            {
                UserConnection connection;
                UserConnections.TryRemove(userName, out connection);
            }
        }

        public void RemoveConnection(string userName, Connection connection)
        {

            if (UserConnections.ContainsKey(userName))
            {
                if (connection != null)
                {
                    var con = UserConnections[userName].Connections?.ToArray().FirstOrDefault(c => c.Hub == connection.Hub && c.ConnectionId == connection.ConnectionId);
                    if (con != null)
                    {
                        UserConnections[userName].Connections.Remove(UserConnections[userName].Connections.FirstOrDefault(c => c.Hub == connection.Hub && c.ConnectionId == connection.ConnectionId));
                    }

                }
            }
        }

        public void SetUser(string userName, Connection connection)
        {

            if (UserConnections.TryAdd(userName, new UserConnection()))
            {
                if (connection != null)
                {
                    UserConnections[userName].Connections.Add(connection);

                }
            }
        }

        public void ClearConnections()
        {
            UserConnections.Clear();
        }
    }
}
