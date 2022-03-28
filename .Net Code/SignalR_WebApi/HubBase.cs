using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Web.Api.Hubs.Interfaces;
using System;
using System.Threading.Tasks;

namespace Web.Api.Hubs
{
    [Authorize]
    public abstract class HubBase<T> : Hub<T> where T : class
    {
        public IUserManager _userManager;
        protected HubBase(IUserManager userManager) : base()
        {
            _userManager = userManager;
        }

        public override Task OnConnectedAsync()
        {
            base.OnConnectedAsync();
            if (!string.IsNullOrEmpty(Context.User.Identity.Name))
            {
                _userManager.AddConnection(Context.User.Identity.Name, new Utility.Connection(typeof(T).Name, Context.ConnectionId));
            }
            return ConnectionsChanged();

        }
        public override Task OnDisconnectedAsync(Exception exception)
        {
            base.OnDisconnectedAsync(exception);
            if (!string.IsNullOrEmpty(Context.User.Identity.Name))
            {

                _userManager.RemoveConnection(Context.User.Identity.Name, new Utility.Connection(typeof(T).Name, Context.ConnectionId));

            }
            return ConnectionsChanged();
        }

        public virtual Task ConnectionsChanged()
        {
            return Task.Run(() => { });
        }

        public virtual Task ConnectionCheck()
        {
            return default;
        }
        public virtual Task ConnectionCheckResponse()
        {
            if (!string.IsNullOrEmpty(Context.User.Identity.Name))
            {
                _userManager.AddConnection(Context.User.Identity.Name, new Utility.Connection(typeof(T).Name, Context.ConnectionId));
            }
            return ConnectionsChanged();
        }
    }
}
