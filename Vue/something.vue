<template>
    <v-textarea ref="textField"
                  :value="overrideValue"
                  :clearable="isEditMode"
                  :label="label"
                  :type="type"
                  :readonly="readonly"
                  hide-details="auto"
                  :hint="_hintText"
                  class="inputFielEditor">
        <template v-slot:prepend v-if="fieldToolTip">
            <v-tooltip bottom>
                <template v-slot:activator="{ on }">
                    <v-icon small v-on="on" color="accent">$infoCircle</v-icon>
                </template>
                {{fieldToolTip}}
            </v-tooltip>
        </template>
        <template v-slot:append>
            <v-fade-transition leave-absolute>
                <v-progress-circular v-if="loading" size="16" color="primary" indeterminate></v-progress-circular>
                <v-btn icon x-small v-if="!editMode && hasEditPermission" @click="editClicked" color="accent" title="Edit/Override Field">
                    <v-icon small >$edit</v-icon>
                </v-btn>
                <v-btn icon x-small v-if="isEditMode" @click="cancelClicked" color="accent" title="Cancel changes" >
                    <v-icon small>$cancel</v-icon>
                </v-btn>
            </v-fade-transition>
        </template>
        <template v-slot:append-outer>
            <v-btn icon x-small v-if="hasOverride && hasEditPermission && !isEditMode" @click="deleteClicked" color="accent" title="Delete override"  >
                <v-icon small>$delete</v-icon>
            </v-btn>
            <v-btn icon x-small v-if="isEditMode" @click="saveClicked" color="accent"  title="Save changes" >
                <v-icon small>$save</v-icon>
            </v-btn>
        </template>
    </v-textarea>
</template>

<script lang="ts">
    import { Component, Vue, Prop } from 'vue-property-decorator'
    import { IOverrideAttributes, IEntityColumnInfo } from '@/utils/models/overrideModels';
    import { DateFormatter } from "@/mixins/dateFormatter";


    @Component({
        name: 'TextAreaEditor',
        components: {
        },
        mixins: [DateFormatter]
    })
    export default class InpuFieldEditor extends Vue {
        @Prop() readonly originalValue!: any;
        @Prop() readonly originalOverride!: IOverrideAttributes;
        @Prop() readonly entityColumnInfo!: IEntityColumnInfo;
        @Prop() readonly label!: string;
        @Prop({ default: false }) readonly persistentHint!: boolean;
        @Prop() readonly hintText!: string;
        @Prop() readonly toolTip!: string;
        @Prop({ required: true }) readonly parentField!: string;
        @Prop({ default: "text" }) readonly type!: string;
        @Prop() readonly delimiter!: string;

        newOverride: IOverrideAttributes | undefined = undefined;
        loading: boolean = false;
        readonly: boolean = true;
        clearable: boolean = false;
        editMode: boolean = false;
        overrideValue: any = null;
        userCanEdit: boolean = true;

        get isEditMode(): boolean {
            return this.hasEditPermission && this.editMode;
        }
        get hasOverride(): boolean {
            if (this.originalOverride) {
                return true;
            }
            return false;
        }
        get _hintText(): string {
            if (this.hintText) {
                return this.hintText;
            }
            if (this.originalOverride) {
                if (this.originalOverride.lastModifiedBy) {
                    return `Override: ${this.toLocaleDateString((this.originalOverride.modifiedDate == null ? this.originalOverride.createdDate : this.originalOverride.modifiedDate))} by: ${this.originalOverride.lastModifiedBy}`;
                }
            }
            return '';
        }
        get fieldToolTip(): string | null {
            if (this.toolTip) {
                return this.toolTip;
            }
            if (this.entityColumnInfo) {
                return this.entityColumnInfo.tooltip;
            }
            return null;
        }
        get hasEditPermission(): boolean {
            if (this.entityColumnInfo) {
                return this.entityColumnInfo.canOverride ?? false;
            }
            return false;
        }
        get hideDetails(): boolean {
            if (this._hintText) {
                return this._hintText.length === 0;
            }
            return true;
        }
        public editClicked(args): void {
            if (this.hasEditPermission) {

                this.editMode = true;
                this.readonly = !this.editMode;
            }
        }
        public cancelClicked(args): void {
            this.editMode = false;
            this.readonly = !this.editMode;
            this.InitializeOverrideValue();
            let ele = this.$refs.textField as any;
            ele.$data.lazyValue = this.overrideValue;
        }
        public deleteClicked(args): void {
            this.editMode = false;
            this.readonly = !this.editMode;
            this.loading = true;
            this.$emit("delete-clicked", this.originalOverride);
        }
        public saveClicked(args): void {
            let obj = {} as IOverrideAttributes;
            let ele = this.$refs.textField as any;
            this.overrideValue = ele.$data.lazyValue;

            obj.columnName = this.entityColumnInfo.columnName;
            obj.overrideValue = this.overrideValue;


            this.editMode = false;
            this.readonly = !this.editMode;
            this.loading = true;
            this.$emit("save-clicked", obj);

        }
        public InitializeOverrideValue(): void {
            if (this.originalOverride) {
                this.overrideValue = this.originalOverride.overrideValue;

            } else {
                this.overrideValue = this.originalValue;
            }
        }
        beforeMount() {
            this.InitializeOverrideValue();
        }
        updated() {
            this.InitializeOverrideValue();
        }
    }

</script>
