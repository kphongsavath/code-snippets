using System.Threading.Tasks;

namespace Web.Api.Hubs.Interfaces
{
    public interface IUserHub
    {
        Task UserConnectionsChanged();
        Task ConnectionCheck();
    }
}
