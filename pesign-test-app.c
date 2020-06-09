/*
 * Copyright 2013 Red Hat, Inc.
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author(s): Peter Jones <pjones@redhat.com>
 */


#include <stdint.h>

#include <efi.h>
#include <efilib.h>

EFI_STATUS
efi_main

	(EFI_HANDLE image_handle __attribute__((__unused__)),
	 EFI_SYSTEM_TABLE *systab __attribute__((__unused__)))
{
	InitializeLib(image_handle, systab);

	Print(L"This is a test application that should be completely safe.\n");

	return EFI_SUCCESS;
}
