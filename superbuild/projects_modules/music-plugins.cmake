function(music_plugins_project)

    set(external_project music-plugins)

    list(APPEND ${external_project}_dependencies
        dtk
        ITK
        VTK
        DCMTK
        medInria
        mmg
        tetgen
        eigen
        qwt
        quazip
        ZLIB
        )

    if (${USE_RealTimeWorkspace})
        list(APPEND ${external_project}_dependencies
            jsoncons
            asio
            websocketpp
            openssl
        )
    endif()

    if (USE_Python)
        list(APPEND ${external_project}_dependencies
            pyncpp
            )
    endif()

    EP_Initialisation(${external_project}
        USE_SYSTEM OFF
        BUILD_SHARED_LIBS ON
        REQUIRED_FOR_PLUGINS ON
        NO_CONFIG_FILE
        )

    if (NOT USE_SYSTEM_${external_project})

        set(git_url ${GITHUB_PREFIX}Inria-Asclepios/music.git)
        set(git_tag musicardio4.0.x)

        set(cmake_args
            ${ep_common_cache_args}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE_medInria}
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS_${external_project}}
            -DQt5_ROOT=${Qt5_DIR}
            -Ddtk_ROOT:FILEPATH=${dtk_ROOT}
            -DITK_ROOT:FILEPATH=${ITK_ROOT}
            -DVTK_ROOT:FILEPATH=${VTK_ROOT}
            -DDCMTK_ROOT:FILEPATH=${DCMTK_ROOT}
            -DmedInria_ROOT:FILEPATH=${medInria_ROOT}
            -DBoost_INCLUDE_DIR=${Boost_INCLUDE_DIR}
            -Djsoncons_ROOT:FILEPATH=${jsoncons_ROOT}
            -Dasio_ROOT:FILEPATH=${asio_ROOT}
            -Dwebsocketpp_ROOT:FILEPATH=${websocketpp_ROOT}
            -Dopenssl_ROOT:FILEPATH=${openssl_ROOT}
            -DOPENSSL_ROOT_DIR:FILEPATH=${OPENSSL_ROOT_DIR} 
            -DOPENSSL_BUILD:FILEPATH=${OPENSSL_BUILD}
            -DEigen3_ROOT:PATH=${eigen_ROOT}
            -Dmmg_ROOT:PATH=${mmg_ROOT}
            -DQWT_INCLUDE_DIR:PATH=${qwt_INCLUDE_DIR}
            -Dqwt_ROOT:PATH=${qwt_ROOT}
            -Dtetgen_ROOT:PATH=${tetgen_ROOT}
            -DQuaZip-Qt5_ROOT:PATH=${quazip_ROOT}
            -DZLIB_ROOT:PATH=${ZLIB_ROOT}
            -DUSE_RealTimeWorkspace=${USE_RealTimeWorkspace}
            )

        if (USE_Python)
          list(APPEND cmake_args
              -Dpyncpp_ROOT:PATH=${pyncpp_ROOT}
              )
        endif()

        if (OpenMP_ROOT)
            list(APPEND cmake_args
                -DOpenMP_ROOT:PATH=${OpenMP_ROOT}
                )
        endif()

        epComputPath(${external_project})
        ExternalProject_Add(${external_project}
            PREFIX ${EP_PATH_SOURCE}
            SOURCE_DIR ${EP_PATH_SOURCE}/${external_project}
            BINARY_DIR ${build_path}
            TMP_DIR ${tmp_path}
            STAMP_DIR ${stamp_path}
            GIT_REPOSITORY ${git_url}
            GIT_TAG ${git_tag}
            CMAKE_GENERATOR ${gen}
            CMAKE_GENERATOR_PLATFORM ${CMAKE_GENERATOR_PLATFORM}
            CMAKE_ARGS ${cmake_args}
            DEPENDS ${${external_project}_dependencies}
            INSTALL_COMMAND ""
            UPDATE_COMMAND ""
            )

        set(EXTERNAL_PROJECT_PLUGINS_LEGACY_DIRS ${EXTERNAL_PROJECT_PLUGINS_LEGACY_DIRS} "${build_path}" PARENT_SCOPE)

        ExternalProject_Get_Property(${external_project} binary_dir)
        set(${external_project}_ROOT ${binary_dir} PARENT_SCOPE)

        ExternalProject_Get_Property(${external_project} source_dir)
        set(${external_project}_SOURCE_DIR ${source_dir} PARENT_SCOPE)

    endif()

if (WIN32)
    get_property(GENERATOR_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(${GENERATOR_MULTI_CONFIG})
        file(TO_NATIVE_PATH ${ZLIB_ROOT} ZLIB_BIN_BASE)
        set(CONFIG_MODE $<$<CONFIG:debug>:Debug>$<$<CONFIG:release>:Release>$<$<CONFIG:MinSizeRel>:MinSizeRel>$<$<CONFIG:RelWithDebInfo>:RelWithDebInfo>)  
        set(MED_BIN_BASE ${MED_BIN_BASE}\\${CONFIG_MODE}\\bin)  
  
        if(USE_SYSTEM_${external_project})
            add_custom_target(create_${external_project}_links ALL
                COMMAND for %%I in ( ${ZLIB_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
                )
        else()
            add_custom_command(TARGET ${external_project}
                POST_BUILD
                COMMAND for %%I in ( ${ZLIB_BIN_BASE}\\bin\\${CONFIG_MODE}\\*.dll ) do (if EXIST ${MED_BIN_BASE}\\%%~nxI (del /S ${MED_BIN_BASE}\\%%~nxI & mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI) else mklink /H ${MED_BIN_BASE}\\%%~nxI %%~fI)
                )
        endif()
    endif()
endif()

endfunction()
