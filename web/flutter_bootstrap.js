{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement: document.getElementById('flutter_target'),
    });
    await appRunner.runApp();

    // Flutter 앱 로드 완료 → 로딩 화면 페이드아웃
    var loading = document.getElementById('loading-screen');
    if (loading) {
      loading.classList.add('hidden');
      setTimeout(function () {
        if (loading.parentNode) loading.parentNode.removeChild(loading);
      }, 700);
    }
  },
});
