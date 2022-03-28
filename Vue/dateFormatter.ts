import { Component, Vue } from 'vue-property-decorator';

declare module 'vue/types/vue' {
    // 3. Declare augmentation for Vue WITH EXPORT
    export interface Vue {
        /**
         * Formats date to - mm/dd/yyyy
         * @param dt Date to format
         */
        formatShortDate(dt: string | undefined | null): string;

        /**
         * Formats date to - mmm dd, yyyy
         * @param dt Date to format
         */
        formatShortMonthDate(dt: string | undefined | null): string;

        /**
         * Formats date to - month dd, yyyy
         * @param dt Date to format
         */
        formatLongMonthDate(dt: string | undefined | null): string;

        /**
         * Formats date to - mm/dd/yyyy, hh:mm am/pm
         * @param dt Date to format
         */
        formatDateTime(dt: string | undefined | null): string;

        /**
         * Formats date to - mmm dd, yyyy, hh:mm am/pm
         * @param dt Date to format
         */
        formatShortMonthDateTime(dt: string | undefined | null): string;

        /**
         * Formats date to - month dd, yyyy, hh:mm am/pm
         * @param dt Date to format
         */
        formatLongMonthDateTime(dt: string | undefined | null): string;

        /**
         * Formats date to - MM/dd/yyyy, hh:mm:ss PM/AM using the current Locale
         * @param dt Date to format
         */
        toLocalString(dt: string | undefined | null): string;

        /**
         * Formats date to - MM/dd/yyyy using the current Locale
         * @param dt Date to format
         */
        toLocaleDateString(dt: string | undefined | null): string;

        /**
         * Formats date to - hh:mm am/pm using the current Locale
         * @param dt Date to format
         */
        toLocaleTimeString(dt: string | undefined | null): string;

        /**
         * Formats date to - DDD mmm dd yyyy
         * @param dt Date to format
         */
        toDateString(dt: string | undefined | null): string;

        /**
         * Adds specified number of days to given date 
         * @param dt Start date
         * @param days Number of days to add
         */
        addDays(dt: string | undefined | null, days: number): string;

        /**
         * Custom Date format using the Intl.DateTimeFormat method
         * @param dt Date to format (String data type)
         * @param format DateTimeFormat Object
         */
        formatStringCustomDate(dt: string | undefined | null, format: object): string;

        /**
         * Custom Date format using the Intl.DateTimeFormat method
         * @param dt Date to format (Date data type)
         * @param format DateTimeFormat Object
         */
        formatCustomDate(dt: Date, format: object): string;

        /**
         * Returns a string representation of date/time elapsed from given date
         * @param dt Start date
         */
        fromDateNow(dt: string | undefined | null): string

        /**
         * Returns a string representation of day from given date
         * @param dt Date
         */
        getDayName(dt: string | undefined | null): string
    }
}


@Component
export class DateFormatter extends Vue {
    private weekday: Array<string> = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"];

    //https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat/DateTimeFormat

    public formatShortDate(dt: string | undefined | null): string {
        if (dt) {
            return (new Intl.DateTimeFormat([], {
                month: "numeric", year: "numeric", day: "numeric"
            })).format(new Date(dt))
        }
        return '';
    }
    //  mmm dd, yyyy
    public formatShortMonthDate(dt: string | undefined | null): string {
        if (dt) {
            return (new Intl.DateTimeFormat([], {
                month: "short", year: "numeric", day: "numeric"
            })).format(new Date(dt))
        }
        return '';
    }

    //  month dd, yyyy
    public formatLongMonthDate(dt: string | undefined | null): string {
        if (dt) {
            return (new Intl.DateTimeFormat([], {
                month: "long", year: "numeric", day: "numeric"
            })).format(new Date(dt))
        }
        return '';
    }
    //  mm/dd/yyyy, hh:mm am/pm
    public formatDateTime(dt: string | undefined | null): string {
        if (dt) {
            return (new Intl.DateTimeFormat([], {
                month: "numeric", year: "numeric", day: "numeric", hour: "numeric", minute: "numeric"
            })).format(new Date(dt))
        }
        return '';
    }

    //  mmm dd, yyyy, hh:mm am/pm
    public formatShortMonthDateTime(dt: string | undefined | null): string {
        if (dt) {
            return (new Intl.DateTimeFormat([], {
                month: "short", year: "numeric", day: "numeric", hour: "numeric", minute: "numeric"
            })).format(new Date(dt))
        }
        return '';
    }

    //  month dd, yyyy, hh:mm am/pm
    public formatLongMonthDateTime(dt: string | undefined | null): string {
        if (dt) {
            return (new Intl.DateTimeFormat([], {
                month: "long", year: "numeric", day: "numeric", hour: "numeric", minute: "numeric"
            })).format(new Date(dt))
        }
        return '';
    }

    // MM/dd/yyyy, hh:mm:ss PM/AM"
    public toLocalString(dt: string | undefined | null): string {
        if (dt) {
            return (new Date(dt)).toLocaleString();
        }
        return '';
    }
    // MM/dd/yyyy
    public toLocaleDateString(dt: string | undefined | null): string {
        if (dt) {
            return (new Date(dt)).toLocaleDateString();
        }
        return '';
    }


    public toLocaleTimeString(dt: string | undefined | null): string {
        if (dt) {
            return (new Date(dt)).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
        }
        return '';
    }
    // DDD mmm dd yyyy
    public toDateString(dt: string | undefined | null): string {
        if (dt) {
            return (new Date(dt)).toDateString();
        }
        return '';
    }
    public addDays(dt: string | undefined | null, days: number): string {

        let date: Date = (dt === undefined || dt === null) ? new Date() : new Date(dt);
        date.setDate(date.getDate() + days);
        return date.toLocaleDateString();

    }
    public formatStringCustomDate(dt: string | undefined | null, format: object): string {

        let date: Date = (dt === undefined || dt === null) ? new Date() : new Date(dt);
        return (new Intl.DateTimeFormat([], format)).format(date);
    }
    public formatCustomDate(dt: Date, format: object): string {

        return (new Intl.DateTimeFormat([], format)).format(dt);
    }
    public fromDateNow(dt: string | undefined | null): string {
        let date: Date = (dt === undefined || dt === null) ? new Date() : new Date(dt);
        let dateNow = new Date();
        var Difference_In_Time = dateNow.getTime() - date.getTime();

        let hours = Math.floor(Difference_In_Time / 3.6e6);
        let days = Math.floor(Difference_In_Time / (1000 * 3600 * 24));
        let months = Math.floor((Difference_In_Time / 1000) / (60 * 60 * 24 * 7 * 4));
        let yearAgo = new Date();
        yearAgo.setDate(yearAgo.getDate() - 365);

        let years = yearAgo.getFullYear() - date.getFullYear();

        let str = 'more than a year ago';
        if (years > 0) {
            if (years === 1) {
                str = 'a year ago';
            }
        } else if (months > 0) {
            if (months === 1) {
                str = 'a month ago';
            } else {
                str = months + ' months ago';
            }
        } else if (days > 0) {
            if (days === 1) {
                str = 'a day ago';
            } else {
                str = days + ' days ago';
            }
        } else if (hours > 0) {
            if (hours === 1) {
                str = 'an hour ago';
            } else {
                str = hours + ' hours ago';
            }
        } else {
            str = 'moments ago';
        }
        return str;

    }

    public getDayName(dt: string | undefined | null): string {
        let date: Date = (dt === undefined || dt === null) ? new Date() : new Date(dt);
        return this.weekday[date.getDay()];
    }
}