using Web.Api.Hubs.Utility;
using System.Collections.Concurrent;

namespace Web.Api.Hubs.Interfaces
{
    public interface IUserManager
    {
        ConcurrentDictionary<string, UserConnection> UserConnections { get; set; }
        void AddConnection(string userName, Connection connection);
        void RemoveConnection(string userName, Connection connection);

        void SetUser(string userName, Connection connection);
        void RemoveUser(string userName);

        void ClearConnections();
    }
}
