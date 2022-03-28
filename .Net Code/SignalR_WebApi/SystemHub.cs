using Web.Api.Hubs.Interfaces;
using System.Threading.Tasks;

namespace Web.Api.Hubs
{
    public class SystemHub : HubBase<ISystemHub>
    {
        public SystemHub(IUserManager userManager) : base(userManager)
        {

        }
        public override Task ConnectionsChanged()
        {
            return Clients.All.UserConnectionsChanged();
        }
    }
}
