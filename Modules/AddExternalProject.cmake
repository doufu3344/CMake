# Requires CVS CMake for 'function' and '-E touch' and '--build'


find_package(CVS)
find_package(Subversion)


function(get_external_project_directories base_dir_var build_dir_var downloads_dir_var install_dir_var sentinels_dir_var source_dir_var tmp_dir_var)
  set(base "${CMAKE_BINARY_DIR}/CMakeExternals")
  set(${base_dir_var} "${base}" PARENT_SCOPE)
  set(${build_dir_var} "${base}/Build" PARENT_SCOPE)
  set(${downloads_dir_var} "${base}/Downloads" PARENT_SCOPE)
  set(${install_dir_var} "${base}/Install" PARENT_SCOPE)
  set(${sentinels_dir_var} "${base}/Sentinels" PARENT_SCOPE)
  set(${source_dir_var} "${base}/Source" PARENT_SCOPE)
  set(${tmp_dir_var} "${base}/tmp" PARENT_SCOPE)
endfunction(get_external_project_directories)


function(get_configure_build_working_dir name working_dir_var)
  get_external_project_directories(base_dir build_dir downloads_dir install_dir
    sentinels_dir source_dir tmp_dir)

  get_target_property(dir ${name} AEP_CONFIGURE_DIR)
  if(dir)
    if (IS_ABSOLUTE "${dir}")
      set(working_dir "${dir}")
    else()
      set(working_dir "${source_dir}/${name}/${dir}")
    endif()
  else()
    set(working_dir "${build_dir}/${name}")
  endif()

  set(${working_dir_var} "${working_dir}" PARENT_SCOPE)
endfunction(get_configure_build_working_dir)


function(get_configure_command_id name cfg_cmd_id_var)
  get_target_property(cmd ${name} AEP_CONFIGURE_COMMAND)

  if(cmd STREQUAL "")
    # Explicit empty string means no configure step for this project
    set(${cfg_cmd_id_var} "none" PARENT_SCOPE)
  else()
    if(NOT cmd)
      # Default is "use cmake":
      set(${cfg_cmd_id_var} "cmake" PARENT_SCOPE)
    else()
      # Otherwise we have to analyze the value:
      if(cmd MATCHES "/configure$")
        set(${cfg_cmd_id_var} "configure" PARENT_SCOPE)
      else()
        if(cmd MATCHES "cmake")
          set(${cfg_cmd_id_var} "cmake" PARENT_SCOPE)
        else()
          if(cmd MATCHES "config")
            set(${cfg_cmd_id_var} "configure" PARENT_SCOPE)
          else()
            set(${cfg_cmd_id_var} "unknown:${cmd}" PARENT_SCOPE)
          endif()
        endif()
      endif()
    endif()
  endif()
endfunction(get_configure_command_id)


function(mkdir d)
  file(MAKE_DIRECTORY "${d}")
  #message(STATUS "mkdir d='${d}'")
  if(NOT EXISTS "${d}")
    message(FATAL_ERROR "error: dir '${d}' does not exist after file(MAKE_DIRECTORY call...")
  endif()
endfunction(mkdir)


function(add_external_project_download_command name)
  set(added 0)
  get_external_project_directories(base_dir build_dir downloads_dir install_dir
    sentinels_dir source_dir tmp_dir)


  if(NOT added)
  get_target_property(cmd ${name} AEP_DOWNLOAD_COMMAND)
  if(cmd STREQUAL "")
    # Explicit empty string means no download step for this project
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-download
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
      WORKING_DIRECTORY ${sentinels_dir}
      COMMENT "No download step for '${name}'"
      DEPENDS ${sentinels_dir}/CMakeExternals-directories
      )
    set(added 1)
  else()
    if(cmd)
      set(args "")
      get_target_property(download_args ${name} AEP_DOWNLOAD_ARGS)
      if(download_args)
        set(args "${download_args}")
        separate_arguments(args)
      endif()

      add_custom_command(
        OUTPUT ${sentinels_dir}/${name}-download
        COMMAND ${cmd} ${args}
        COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
        WORKING_DIRECTORY ${downloads_dir}
        COMMENT "Performing download step for '${name}'"
        DEPENDS ${sentinels_dir}/CMakeExternals-directories
        )
      set(added 1)
    else()
      # No explicit DOWNLOAD_COMMAND property. Look for other properties
      # indicating which download method to use in the logic below...
    endif()
  endif()
  endif()


  if(NOT added)
  get_target_property(cvs_repository ${name} AEP_CVS_REPOSITORY)
  if(cvs_repository)
    if(NOT CVS_EXECUTABLE)
      message(FATAL_ERROR "error: could not find cvs for checkout of ${name}")
    endif()

    get_target_property(cvs_module ${name} AEP_CVS_MODULE)
    if(NOT cvs_module)
      message(FATAL_ERROR "error: no CVS_MODULE")
    endif()

    get_target_property(tag ${name} AEP_CVS_TAG)
    set(cvs_tag)
    if(tag)
      set(cvs_tag ${tag})
    endif()

    set(args -d ${cvs_repository} co ${cvs_tag} -d ${name} ${cvs_module})

    set(repository ${cvs_repository})
    set(module ${cvs_module})
    set(tag ${cvs_tag})

    configure_file(
      "${CMAKE_ROOT}/Modules/RepositoryInfo.txt.in"
      "${sentinels_dir}/${name}-cvsinfo.txt"
      @ONLY
    )

    mkdir("${source_dir}/${name}")
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-download
      COMMAND ${CVS_EXECUTABLE} ${args}
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
      WORKING_DIRECTORY ${source_dir}
      COMMENT "Performing download step (CVS checkout) for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-cvsinfo.txt
    )
    set(added 1)
  endif()
  endif(NOT added)


  if(NOT added)
  get_target_property(svn_repository ${name} AEP_SVN_REPOSITORY)
  if(svn_repository)
    if(NOT Subversion_SVN_EXECUTABLE)
      message(FATAL_ERROR "error: could not find svn for checkout of ${name}")
    endif()

    get_target_property(tag ${name} AEP_SVN_TAG)
    set(svn_tag)
    if(tag)
      set(svn_tag ${tag})
    endif()

    set(args co ${svn_repository} ${svn_tag} ${name})

    set(repository ${svn_repository})
    set(module)
    set(tag ${svn_tag})

    configure_file(
      "${CMAKE_ROOT}/Modules/RepositoryInfo.txt.in"
      "${sentinels_dir}/${name}-svninfo.txt"
      @ONLY
    )

    mkdir("${source_dir}/${name}")
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-download
      COMMAND ${Subversion_SVN_EXECUTABLE} ${args}
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
      WORKING_DIRECTORY ${source_dir}
      COMMENT "Performing download step (SVN checkout) for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-svninfo.txt
    )
    set(added 1)
  endif()
  endif(NOT added)


  if(NOT added)
  get_target_property(dir ${name} AEP_DIR)
  if(dir)
    get_filename_component(abs_dir "${dir}" ABSOLUTE)

    set(repository "add_external_project DIR")
    set(module "${abs_dir}")
    set(tag "")

    configure_file(
      "${CMAKE_ROOT}/Modules/RepositoryInfo.txt.in"
      "${sentinels_dir}/${name}-dirinfo.txt"
      @ONLY
    )

    mkdir("${source_dir}/${name}")
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-download
      COMMAND ${CMAKE_COMMAND} -E remove_directory ${source_dir}/${name}
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${abs_dir} ${source_dir}/${name}
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
      WORKING_DIRECTORY ${source_dir}
      COMMENT "Performing download step (DIR copy) for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-dirinfo.txt
    )
    set(added 1)
  endif()
  endif(NOT added)


  if(NOT added)
  get_target_property(tar ${name} AEP_TAR)
  if(tar)
    mkdir("${source_dir}/${name}")
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-download
      COMMAND ${CMAKE_COMMAND} -Dfilename=${tar} -Dtmp=${tmp_dir}/${name} -Ddirectory=${source_dir}/${name} -P ${CMAKE_ROOT}/Modules/UntarFile.cmake
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
      WORKING_DIRECTORY ${source_dir}
      COMMENT "Performing download step (TAR untar) for '${name}'"
      DEPENDS ${tar}
    )
    set(added 1)
  endif()
  endif(NOT added)


  if(NOT added)
  get_target_property(tgz ${name} AEP_TGZ)
  if(tgz)
    mkdir("${source_dir}/${name}")
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-download
      COMMAND ${CMAKE_COMMAND} -Dfilename=${tgz} -Dtmp=${tmp_dir}/${name} -Ddirectory=${source_dir}/${name} -P ${CMAKE_ROOT}/Modules/UntarFile.cmake
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
      WORKING_DIRECTORY ${source_dir}
      COMMENT "Performing download step (TGZ untar) for '${name}'"
      DEPENDS ${tgz}
    )
    set(added 1)
  endif()
  endif(NOT added)


  if(NOT added)
  get_target_property(tgz_url ${name} AEP_TGZ_URL)
  if(tgz_url)
    set(repository "add_external_project TGZ_URL")
    set(module "${tgz_url}")
    set(tag "")

    configure_file(
      "${CMAKE_ROOT}/Modules/RepositoryInfo.txt.in"
      "${sentinels_dir}/${name}-urlinfo.txt"
      @ONLY
    )

    mkdir("${source_dir}/${name}")
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-download
      COMMAND ${CMAKE_COMMAND} -Dremote=${tgz_url} -Dlocal=${downloads_dir}/${name}.tgz -P ${CMAKE_ROOT}/Modules/DownloadFile.cmake
      COMMAND ${CMAKE_COMMAND} -Dfilename=${downloads_dir}/${name} -Dtmp=${tmp_dir}/${name} -Ddirectory=${source_dir}/${name} -P ${CMAKE_ROOT}/Modules/UntarFile.cmake
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
      WORKING_DIRECTORY ${source_dir}
      COMMENT "Performing download step (TGZ_URL download and untar) for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-urlinfo.txt
    )
    set(added 1)
  endif()
  endif(NOT added)


  if(NOT added)
  get_target_property(tar_url ${name} AEP_TAR_URL)
  if(tar_url)
    set(repository "add_external_project TAR_URL")
    set(module "${tar_url}")
    set(tag "")

    configure_file(
      "${CMAKE_ROOT}/Modules/RepositoryInfo.txt.in"
      "${sentinels_dir}/${name}-urlinfo.txt"
      @ONLY
    )

    mkdir("${source_dir}/${name}")
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-download
      COMMAND ${CMAKE_COMMAND} -Dremote=${tar_url} -Dlocal=${downloads_dir}/${name}.tar -P ${CMAKE_ROOT}/Modules/DownloadFile.cmake
      COMMAND ${CMAKE_COMMAND} -Dfilename=${downloads_dir}/${name} -Dtmp=${tmp_dir}/${name} -Ddirectory=${source_dir}/${name} -P ${CMAKE_ROOT}/Modules/UntarFile.cmake
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-download
      WORKING_DIRECTORY ${source_dir}
      COMMENT "Performing download step (TAR_URL download and untar) for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-urlinfo.txt
    )
    set(added 1)
  endif()
  endif(NOT added)


  if(NOT added)
    message(SEND_ERROR "error: no download info for '${name}'")
  endif(NOT added)
endfunction(add_external_project_download_command)


function(add_external_project_configure_command name)
  get_external_project_directories(base_dir build_dir downloads_dir install_dir
    sentinels_dir source_dir tmp_dir)
  get_configure_build_working_dir(${name} working_dir)

  # Create the working_dir for configure, build and install steps:
  #
  mkdir("${working_dir}")
  add_custom_command(
    OUTPUT ${sentinels_dir}/${name}-working_dir
    COMMAND ${CMAKE_COMMAND} -E make_directory ${working_dir}
    COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-working_dir
    DEPENDS ${sentinels_dir}/${name}-download
    )

  get_target_property(cmd ${name} AEP_CONFIGURE_COMMAND)
  if(cmd STREQUAL "")
    # Explicit empty string means no configure step for this project
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-configure
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-configure
      WORKING_DIRECTORY ${working_dir}
      COMMENT "No configure step for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-working_dir
      )
  else()
    if(NOT cmd)
      set(cmd ${CMAKE_COMMAND})
    endif()

    set(args "")
    get_target_property(configure_args ${name} AEP_CONFIGURE_ARGS)
    if(configure_args)
      set(args "${configure_args}")
      separate_arguments(args)
    endif()

    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-configure
      COMMAND ${cmd} ${args}
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-configure
      WORKING_DIRECTORY ${working_dir}
      COMMENT "Performing configure step for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-working_dir
      )
  endif()
endfunction(add_external_project_configure_command)


function(add_external_project_build_command name)
  get_external_project_directories(base_dir build_dir downloads_dir install_dir
    sentinels_dir source_dir tmp_dir)
  get_configure_build_working_dir(${name} working_dir)

  get_target_property(cmd ${name} AEP_BUILD_COMMAND)
  if(cmd STREQUAL "")
    # Explicit empty string means no build step for this project
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-build
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-build
      WORKING_DIRECTORY ${working_dir}
      COMMENT "No build step for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-configure
      )
  else()
    get_configure_command_id(${name} cfg_cmd_id)

    if(NOT cmd)
      set(cmd make)
      if(cfg_cmd_id STREQUAL "cmake")
        get_target_property(cfg_cmd ${name} AEP_CONFIGURE_COMMAND)
        if(cfg_cmd)
          set(cmd ${cfg_cmd})
        else()
          set(cmd ${CMAKE_COMMAND})
        endif()
      endif()
    endif()

    get_target_property(args ${name} AEP_BUILD_ARGS)
    if(NOT args)
      set(args)
      if(cfg_cmd_id STREQUAL "cmake")
        set(args --build ${working_dir} --config ${CMAKE_CFG_INTDIR})
      endif()
    endif()

    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-build
      COMMAND ${cmd} ${args}
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-build
      WORKING_DIRECTORY ${working_dir}
      COMMENT "Performing build step for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-configure
      )
  endif()
endfunction(add_external_project_build_command)


function(add_external_project_install_command name)
  get_external_project_directories(base_dir build_dir downloads_dir install_dir
    sentinels_dir source_dir tmp_dir)
  get_configure_build_working_dir(${name} working_dir)

  get_target_property(cmd ${name} AEP_INSTALL_COMMAND)
  if(cmd STREQUAL "")
    # Explicit empty string means no install step for this project
    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-install
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-install
      WORKING_DIRECTORY ${working_dir}
      COMMENT "No install step for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-build
      )
  else()
    get_configure_command_id(${name} cfg_cmd_id)

    if(NOT cmd)
      set(cmd make)
      if(cfg_cmd_id STREQUAL "cmake")
        get_target_property(cfg_cmd ${name} AEP_CONFIGURE_COMMAND)
        if(cfg_cmd)
          set(cmd ${cfg_cmd})
        else()
          set(cmd ${CMAKE_COMMAND})
        endif()
      endif()
    endif()

    get_target_property(args ${name} AEP_INSTALL_ARGS)
    if(NOT args)
      set(args)
      if(cfg_cmd_id STREQUAL "cmake")
        set(args --build ${working_dir} --config ${CMAKE_CFG_INTDIR} --target install)
      endif()
      if(cfg_cmd_id STREQUAL "configure")
        set(args "install")
      endif()
    endif()

    add_custom_command(
      OUTPUT ${sentinels_dir}/${name}-install
      COMMAND ${cmd} ${args}
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/${name}-install
      WORKING_DIRECTORY ${working_dir}
      COMMENT "Performing install step for '${name}'"
      DEPENDS ${sentinels_dir}/${name}-build
      )
  endif()
endfunction(add_external_project_install_command)


function(add_CMakeExternals_target)
  if(NOT TARGET CMakeExternals)
    get_external_project_directories(base_dir build_dir downloads_dir install_dir
      sentinels_dir source_dir tmp_dir)

    # Make the directories at CMake configure time *and* add a custom command
    # to make them at build time. They need to exist at makefile generation
    # time for Borland make and wmake so that CMake may generate makefiles
    # with "cd C:\short\paths\with\no\spaces" commands in them.
    #
    # Additionally, the add_custom_command is still used in case somebody
    # removes one of the necessary directories and tries to rebuild without
    # re-running cmake.
    #
    mkdir("${build_dir}")
    mkdir("${downloads_dir}")
    mkdir("${install_dir}")
    mkdir("${sentinels_dir}")
    mkdir("${source_dir}")
    mkdir("${tmp_dir}")

    add_custom_command(
      OUTPUT ${sentinels_dir}/CMakeExternals-directories
      COMMAND ${CMAKE_COMMAND} -E make_directory ${build_dir}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${downloads_dir}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${install_dir}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${sentinels_dir}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${source_dir}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${tmp_dir}
      COMMAND ${CMAKE_COMMAND} -E touch ${sentinels_dir}/CMakeExternals-directories
      COMMENT "Creating CMakeExternals directories"
    )

    add_custom_target(CMakeExternals ALL
      DEPENDS ${sentinels_dir}/CMakeExternals-directories
    )
  endif()
endfunction(add_CMakeExternals_target)


function(is_known_aep_property_key key result_var)
  set(${result_var} 0 PARENT_SCOPE)

  if(key MATCHES "^BUILD_ARGS|BUILD_COMMAND|CONFIGURE_ARGS|CONFIGURE_COMMAND|CONFIGURE_DIR|CVS_REPOSITORY|CVS_MODULE|CVS_TAG|DEPENDS|DOWNLOAD_ARGS|DOWNLOAD_COMMAND|DIR|INSTALL_ARGS|INSTALL_COMMAND|SVN_REPOSITORY|SVN_TAG|TAR|TAR_URL|TGZ|TGZ_URL$"
  )
    #message(STATUS "info: recognized via MATCHES - key='${key}'")
    set(${result_var} 1 PARENT_SCOPE)
  else()
    message(STATUS "warning: is_known_aep_property_key unknown key='${key}'")
  endif()
endfunction(is_known_aep_property_key)


function(add_external_project name)
  get_external_project_directories(base_dir build_dir downloads_dir install_dir
    sentinels_dir source_dir tmp_dir)


  # Ensure root CMakeExternals target and directories are created.
  # All external projects will depend on this root CMakeExternals target.
  #
  add_CMakeExternals_target()


  # Add a custom target for the external project and make its DEPENDS
  # the output of the final build step:
  #
  add_custom_target(${name} ALL
    DEPENDS ${sentinels_dir}/${name}-install
  )
  set_target_properties(${name} PROPERTIES AEP_IS_EXTERNAL_PROJECT 1)
  add_dependencies(${name} CMakeExternals)


  # Transfer the arguments to this function into target properties for the
  # new custom target we just added so that we can set up all the build steps
  # correctly based on target properties.
  #
  # Loop over ARGN by 2's extracting key/value pairs from the non-explicit
  # arguments to this function:
  #
  list(LENGTH ARGN n)
  set(i 0)
  while(i LESS n)
    math(EXPR j ${i}+1)

    list(GET ARGN ${i} key)
    list(GET ARGN ${j} value)

    is_known_aep_property_key("${key}" is_known_key)

    if(is_known_key)
      if(key STREQUAL "DEPENDS")
        if(NOT value STREQUAL "")
          add_dependencies(${name} ${value})
        else()
          message(STATUS "warning: empty DEPENDS value in add_external_project")
        endif()
      else()
        set_target_properties(${name} PROPERTIES AEP_${key} "${value}")
      endif()
    else()
      message(SEND_ERROR "error: unknown add_external_project key with name='${name}' key='${key}' value='${value}'")
    endif()

    math(EXPR i ${i}+2)
  endwhile()


  # Set up custom build steps based on the target properties.
  # Each step depends on the previous one.
  #
  # The target depends on the output of the final step.
  # (Already set up above in the DEPENDS of the add_custom_target command.)
  #
  add_external_project_download_command(${name})
  add_external_project_configure_command(${name})
  add_external_project_build_command(${name})
  add_external_project_install_command(${name})
endfunction(add_external_project)
