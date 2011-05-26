/* damage_test.c */

#include <stdio.h>                           /* standard I/O stuff */

#ifdef HAVE_CONFIG_H
    #include <config.h>                      /* for autotools */
#endif

#if STDC_HEADERS
    #include <stdlib.h>                      /* standard library stuff */
    #include <string.h>                      /* standard string library */
    #include <time.h>                        /* standard itme library */
    #include <math.h>                        /* standard math library */
#endif

#if HAVE_UNISTD_H
    #include <unistd.h>                      /* used for optarg */
#endif

/* function prototypes */
void usage(char *ProgName);                  /* for Usage function */

int main(int argc, char *argv[])
{
    int opt;                                 /* used for getopt */
    int total_damage = 0;                    /* total damage */
    int damage_done = 430;                   /* damage from spell */
    int mana_cost = 205;                     /* mana cost of spell */
    int mana_pool = 9040;                    /* total mana pool */
    int mana_regen = 124;                    /* total mana regen */
    int extra_damage = 950;                  /* total mana regen */
    float chance = 0.0;                      /* rand chance */
    float second = 0.0;                      /* seconds */
    float crit_percent = 14.81;              /* crit percent */
    float bonus_damage = 1.5;                /* bonus damage on crit default */
    float cast_time = 1.5;                   /* time to cast spell */
    float num_casts = 0.0;                   /* num times spell was cast */
    char ProgName[256];                      /* the name of our program */
    time_t seed;

    /* copy in case we need usage function */
    strncpy(ProgName, argv[0], sizeof(ProgName));

    /* loop until end of arg list */
    while((opt = getopt(argc, argv, "hb:c:d:e:m:p:r:t:")) != EOF)
    {
        switch(opt)
        {
            case 'b':
                sscanf(optarg, "%f", &bonus_damage);
                break;
            case 'c':
                sscanf(optarg, "%f", &crit_percent);
                break;
            case 'd':
                sscanf(optarg, "%d", &damage_done);
                break;
            case 'e':
                sscanf(optarg, "%d", &extra_damage);
                break;
            case 'm':
                sscanf(optarg, "%d", &mana_cost);
                break;
            case 'p':
                sscanf(optarg, "%d", &mana_pool);
                break;
            case 't':
                sscanf(optarg, "%f", &cast_time);
                break;
            case 'r':
                sscanf(optarg, "%d", &mana_regen);
                break;
            case 'h':
            default:
                usage(ProgName);
                return(0);
                break;
        }
    }

    while ((mana_pool - mana_cost) >= 0)
    {
        srandom(time(&seed));

        if (((int)second % 5) == 0)
            mana_pool += mana_regen;

        if (second - ((cast_time * num_casts) + cast_time) >= 0.0)
        {
            num_casts++;
            mana_pool -= mana_cost;
            chance = 1.0 * (random()/(pow(2,31) -1));

            if ((1.0 * (random()/(pow(2,31) -1))) <= crit_percent)
            {
                total_damage += damage_done + (extra_damage * chance) +
                       ((damage_done + (extra_damage * chance)) * bonus_damage);
            }
            else
            {
                total_damage += damage_done + (extra_damage * chance);
            }
        }

        second++;
    }

    printf("Total Time (in seconds) = %.2f\n", second);
    printf("Total Damage = %d\n", total_damage);
    printf("DPS = %f\n", total_damage/second);

    return (0);                              /* exit clean */
}


/******************************************************************************
 * usage() -- print the usage messages for the command utility                *
 *                                                                            *
 * Parameters                                                                 *
 *     char * -- program that was executed                                    *
 * Returns                                                                    *
 *     int -- 0 for success and < 0 for failure                               *
 * Precondition                                                               *
 *     none                                                                   *
 * Postcondition                                                              *
 *     usage message is printed                                               *
 ******************************************************************************/
void usage(char *ProgName)
{
    fprintf(stderr, "\nUsage: %s\n"
               "[-h] [-b <bonus crit damage>] [-c <crit percent>]\n"
               "[-d <damage done avg>] [-e <extra damage max>]\n"
               "[-m <mana cost>] [-p <mana pool>]\n"
               "[-t <cast time>] [-r <mp5>]\n", ProgName);
    fprintf(stderr, "\n"
               "-b\tpercent of bonus damage on crit\n"
               "-c\tcrit chance percentage\n"
               "-d\tdamage done by spell (average low and high)\n"
               "-e\tmax extra damage\n"
               "-h\tprint this usage message\n"
               "-m\thow much mana the spell costs\n"
               "-p\tsize of your mana pool\n"
               "-r\tmana return per/5 seconds (mp5)\n"
               "-t\tspell cast time\n\n");
}
