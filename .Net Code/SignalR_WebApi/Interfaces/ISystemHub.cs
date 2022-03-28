using System.Collections.Generic;
using System.Threading.Tasks;

namespace Web.Api.Hubs.Interfaces
{
    public interface ISystemHub
    {
        Task UserConnectionsChanged();
        Task AuditLogged();
        Task UpdateEntityColumnInfo(EntityColumnInfo entityColumnInfo);
        Task UpdateApiKey(ApiKey key);
        Task UpdateRoles(Roles roles);
        Task UpdateUserRoles(IEnumerable<UserRoles> userRoles);
        Task UpdateUser(UserInfo userRoles);
        Task ApplicationFormSubmitted();
        Task UpdateDepartmentDivision(DepartmentDivision departmentDivision);
    }
}
