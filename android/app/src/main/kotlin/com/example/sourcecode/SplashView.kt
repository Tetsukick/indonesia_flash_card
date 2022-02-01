import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import io.flutter.embedding.android.SplashScreen
import com.tetsukick.indonesia.flash.card.R

class SplashView : SplashScreen {
    override fun createSplashView(context: Context, savedInstanceState: Bundle?): View? =
            LayoutInflater.from(context).inflate(R.layout.splash_view, null, false)

    override fun transitionToFlutter(onTransitionComplete: Runnable) {
        onTransitionComplete.run()
    }
}