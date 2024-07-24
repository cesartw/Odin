package os2

import "core:time"
import "base:runtime"

Fstat_Callback :: proc(f: ^File, allocator: runtime.Allocator) -> (File_Info, Error)

File_Info :: struct {
	fullpath:          string,
	name:              string,

	inode:             u64,
	size:              i64,
	mode:              int,
	type:              File_Type,

	creation_time:     time.Time,
	modification_time: time.Time,
	access_time:       time.Time,
}

file_info_slice_delete :: proc(infos: []File_Info, allocator: runtime.Allocator) {
	for i := len(infos)-1; i >= 0; i -= 1 {
		file_info_delete(infos[i], allocator)
	}
	delete(infos, allocator)
}

file_info_delete :: proc(fi: File_Info, allocator: runtime.Allocator) {
	delete(fi.fullpath, allocator)
}

@(require_results)
fstat :: proc(f: ^File, allocator: runtime.Allocator) -> (File_Info, Error) {
	if f == nil {
		return {}, nil
	} else if f.fstat != nil {
		return f->fstat(allocator)
	}
	return {}, .Invalid_Callback
}

@(require_results)
stat :: proc(name: string, allocator: runtime.Allocator) -> (File_Info, Error) {
	return _stat(name, allocator)
}

lstat :: stat_do_not_follow_links

@(require_results)
stat_do_not_follow_links :: proc(name: string, allocator: runtime.Allocator) -> (File_Info, Error) {
	return _lstat(name, allocator)
}


@(require_results)
same_file :: proc(fi1, fi2: File_Info) -> bool {
	return _same_file(fi1, fi2)
}


last_write_time         :: modification_time
last_write_time_by_name :: modification_time_by_path

@(require_results)
modification_time :: proc(f: ^File) -> (time.Time, Error) {
	TEMP_ALLOCATOR_GUARD()
	fi, err := fstat(f, temp_allocator())
	return fi.modification_time, err
}

@(require_results)
modification_time_by_path :: proc(path: string) -> (time.Time, Error) {
	TEMP_ALLOCATOR_GUARD()
	fi, err := stat(path, temp_allocator())
	return fi.modification_time, err
}
