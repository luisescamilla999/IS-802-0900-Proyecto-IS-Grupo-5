import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ComponentsModule } from '../components/components.module'
import { AdminRoutingModule } from './admin-routing.module';
import { AdminComponent } from './view-admin/admin.component';
import { StatisticsComponent } from './statistics/statistics.component';
import { ExpiryTimeComponent } from './expiry-time/expiry-time.component';
import { ComplaintsComponent } from './complaints/complaints.component';
import { CategoriesComponent } from './categories/categories.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatPaginatorModule } from '@angular/material/paginator';

@NgModule({
  declarations: [
    AdminComponent,
    StatisticsComponent,
    ExpiryTimeComponent,
    ComplaintsComponent,
    CategoriesComponent
  ],
  imports: [
    CommonModule,
    AdminRoutingModule,
    ComponentsModule,
    FormsModule,
    ReactiveFormsModule,
    MatPaginatorModule
  ],
  exports:[
    AdminComponent
  ]
})
export class AdminModule { }
