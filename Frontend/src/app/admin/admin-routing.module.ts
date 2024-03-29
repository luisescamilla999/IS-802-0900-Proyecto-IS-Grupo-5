import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ComplaintsComponent } from './complaints/complaints.component';
import { CategoriesComponent } from './categories/categories.component';
import { ExpiryTimeComponent } from './expiry-time/expiry-time.component';
import { StatisticsComponent } from './statistics/statistics.component';
import { AdminComponent } from './view-admin/admin.component';
import { VigilanteGuard } from './vigilante.guard';


const routes: Routes = [{ path: '', component: AdminComponent, canActivate: [VigilanteGuard],
children:[
  {path: '',component:CategoriesComponent},
  {path: 'complaint',component:ComplaintsComponent},
  {path: 'expiryTime',component:ExpiryTimeComponent},
  {path: 'statistics',component:StatisticsComponent}
]}];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AdminRoutingModule { }