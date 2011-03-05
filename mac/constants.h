/*
 *  constants.h
 *  btp
 *
 *  This file is part of BTP.                                                       
 *  BTP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  BTP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with BTP.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Copyright 2009 Project DoD Inc. All rights reserved.
 *
 */

#define BTP_WAIT_SLEEP 5000000
#define BTP_FARM_BG_TIME 1000
#define BTP_LOOP_TIME 50000
#define MAX_KEY_SIZE 16
#define LETTER_MAX_SIZE 2048
#define EVENT_MAX_SIZE 32

typedef enum
{
    BTP_RETURN_OK,
    BTP_RETURN_ERROR,
	BTP_RETURN_FAIL,
	BTP_RETURN_ERROR_GL,
	BTP_RETURN_ERROR_MEMORY_ALLOCATION,
    BTP_RETURN_FRAMES_NOT_FOUND
} btp_return_t;
