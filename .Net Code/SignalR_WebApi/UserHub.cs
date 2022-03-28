using Web.Api.Hubs.Interfaces;
using System.Threading.Tasks;

namespace OSU.Cancer.Crap.Web.Api.Hubs
{
    public class UserHub : HubBase<IUserHub>
    {
        public UserHub(IUserManager userManager) : base(userManager)
        {

        }

        public override Task ConnectionsChanged()
        {
            return Clients.All.UserConnectionsChanged();
        }

    }
}
