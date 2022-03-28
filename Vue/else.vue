<template>
    <v-row>
        <v-col lg="12" md="12" sm="12">
            <v-data-table v-if="currentTab !== 'ds'"
                          dense
                          :headers="headers"
                          :items="items"
                          item-key="sitecoreId"
                          :loading="dataLoaded"
                          :search="search"
                          multi-sort
                          loading-text="Loading Data.."
                          items-per-page="25"
                          :footer-props="{'items-per-page-options': [25, 50, 100, -1]}">

                <template v-slot:top>
                    <v-toolbar flat color="white">
                        <v-toolbar-title>Department & Division Specialty Link</v-toolbar-title>
                        <v-divider class="mx-4"
                                   inset
                                   vertical></v-divider>
                        <div class="title accent--text text--darken-1 mb-3">
                            <v-btn-toggle v-model="currentTab" tile dense color="accent-3"
                                          group>
                                <v-btn v-for="key in Object.keys(tabs)" :key="key" :value="tabs[key]" small class="my-0">
                                    {{key}}
                                </v-btn>
                            </v-btn-toggle>
                        </div>
                        <v-spacer></v-spacer>
                        <v-text-field v-model="search"
                                      append-icon="$search"
                                      label="Search"
                                      single-line
                                      hide-details></v-text-field>
                        <v-dialog v-model="dialog" max-width="500px">
                            <v-card>
                                <v-card-title>
                                    <span class="headline">{{ deptDivTitle }}</span>
                                </v-card-title>
                                <v-card-text>
                                    <div class="mb-2"><code>Add</code> or <code>Delete</code> doctor specialties for the given department/division</div>
                                    <v-container>
                                        <v-autocomplete v-model="editedItem.doctorSpecialties"
                                                        :items="specialtyList"
                                                        item-text="title"
                                                        return-object
                                                        outlined
                                                        deletable-chips
                                                        small-chips
                                                        label="Doctor Specialties"
                                                        multiple></v-autocomplete>
                                    </v-container>
                                </v-card-text>
                                <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn color="secondary darken-1" text @click="close">Cancel</v-btn>
                                    <v-btn color="primary darken-1" text @click="save">Save</v-btn>
                                </v-card-actions>
                            </v-card>
                        </v-dialog>
                    </v-toolbar>
                </template>
                <template v-slot:item.title="{ item }">
                    {{item.title}}
                </template>
                <template v-slot:item.doctorSpecialties="{ item }">
                    <v-chip-group active-class="primary--text"
                                  column>
                        <v-chip v-for="specialty in item.doctorSpecialties" :key="specialty.id" outlined>
                            {{ specialty.title }}
                        </v-chip>
                    </v-chip-group>
                </template>
                <template v-slot:item.actions="{item }">
                    <v-btn icon color="primary" class="my-1" title="Edit Record" @click="editItem(item)">
                        <v-icon small>$edit</v-icon>
                    </v-btn>
                </template>
            </v-data-table>
            <v-card v-if="currentTab == 'ds'">
                <v-toolbar flat color="white">
                    <v-toolbar-title>Doctor Specialties</v-toolbar-title>
                    <v-divider class="mx-4"
                               inset
                               vertical></v-divider>
                    <div class="title accent--text text--darken-1 mb-3">
                        <v-btn-toggle v-model="currentTab" tile dense color="accent-3"
                                      group>
                            <v-btn v-for="key in Object.keys(tabs)" :key="key" :value="tabs[key]" small class="my-0">
                                {{key}}
                            </v-btn>
                        </v-btn-toggle>
                    </div>
                    <v-spacer></v-spacer>
                    <v-text-field v-model="search"
                                  append-icon="$search"
                                  label="Search"
                                  single-line
                                  hide-details></v-text-field>
                </v-toolbar>
                <v-chip-group class="px-3"
                              active-class="primary--text"
                              column>
                    <v-chip v-for="specialty in filteredSpecialties" :key="specialty.id" outlined>
                        {{ specialty.title }}
                    </v-chip>
                </v-chip-group>
            </v-card>
        </v-col>
    </v-row>
</template>

<script lang="ts">
    import { Component, Vue, Watch } from 'vue-property-decorator'
    import { IHeaders } from '@/utils/models/gridModels';

    import { DateFormatter } from "@/mixins/dateFormatter";
    import { IDepartmentDivision, IDoctorSpecialty } from "@/utils/models/doctorDetailModels";
    import { ApiUtility } from "@/utils/apiUtility";
    import _filter from "lodash-es/filter";


    @Component({
        name: 'DepartmentDivisionMaintenance',
        components: {},
        mixins: [DateFormatter]
    })
    export default class DepartmentDivisionMaintenance extends Vue {
        dataloaded: boolean = false;
        dialog: boolean = false;
        editedIndex: number = -1;
        search: string = '';
        currentTab: string = 'dm';
        items: Array<IDepartmentDivision> = [];
        specialtyList: Array<IDoctorSpecialty> = [];
        editedItem: IDepartmentDivision = {
            id: "",
            templateId: "",
            title: "",
            url: "",
            doctorSpecialties: []
        };
        private _apiUtility!: ApiUtility;

        headers: IHeaders[] = [
            { text: 'Deptartment|Division', value: 'title', sortable: true, filterable: true, },
            { text: 'Linked Doctor Specialties', value: 'doctorSpecialties', align:'start', sortable: false, filterable: true, },
            { text: 'Actions', value: 'actions', sortable: false, filterable: false, },
        ]
        get tabs(): { [key: string]: string; } {
            let dict: { [key: string]: string; } = {};
            dict["Link Maintenance"] = "dm";
            dict["Doctor Specialty List"] = "ds";
            return dict;
        }
        get dataLoaded(): boolean {
            return !(this.dataloaded);
        }
        get deptDivTitle(): string {
            if (this.editedItem) {
                return this.editedItem.title;
            }
            return '';
        }
        get filteredSpecialties(): Array<IDoctorSpecialty> {
            var ds = this.specialtyList;
            var srch = this.search;
            if (this.search) {
                return _filter(ds, function (o) { return (o.title.toLocaleLowerCase()).indexOf(srch.toLocaleLowerCase()) > -1; });

            }
            return ds;
        }
        public editItem(item: IDepartmentDivision): void {
            this.editedIndex = this.items.indexOf(item)
            this.editedItem = Object.assign({}, item)
            this.dialog = true
        }
        public close(): void {
            this.dialog = false
            this.$nextTick(() => {
                this.editedItem = Object.assign({}, null)
                this.editedIndex = -1
            })
        }
        public save(): void {
            this.dataloaded = false;
            //var editingIndex = this.editedIndex;
            this._apiUtility.putData({ url: `${process.env.VUE_APP_CRAP_API_URL}/admin/departmentDivision/Update`, parameters: this.editedItem },
                (resp) => {
                    if (resp.success) {
                        if (resp.data) {
                            this.getData();//this.items[editingIndex] = resp.data;
                        }
                    }
                    this.dataloaded = true;
                });
            this.close()
        }
        public getSpecialtyList(): void {
            this.dataloaded = false;
            this._apiUtility.getData({ url: `${process.env.VUE_APP_CRAP_API_URL}/doctors/doctorSpecialties` },
                (resp) => {
                    if (resp.success) {
                        if (resp.data) {
                            this.specialtyList = resp.data;
                        }
                    }
                    this.dataloaded = true;
                });
        }
        public getData(): void {
            this.dataloaded = false;
            this._apiUtility.getData({ url: `${process.env.VUE_APP_CRAP_API_URL}/admin/departmentDivisions` },
                (resp) => {
                    if (resp.success) {
                        if (resp.data) {
                            this.items = resp.data;
                        }
                    }
                    this.dataloaded = true;
                });
        }
        public processTabChange(): void {
            this.search = '';
        }

        public initializeData(): void {
            this.getData();
            this.getSpecialtyList();

        }
        mounted() {
            Vue.prototype.$systemHub.$on("department-division-updated", (departmentDivision: IDepartmentDivision) => { this.getData(); });
        }
        beforeMount() {
            this._apiUtility = new ApiUtility();
            this.initializeData();
        }
        @Watch('dialog') onPropertyChanged(val: boolean, oldVal: boolean): void { val || this.close(); }
        @Watch('currentTab') currentTab_Changed(val: string, oldVal: string): void { this.processTabChange(); }

    }
</script>
