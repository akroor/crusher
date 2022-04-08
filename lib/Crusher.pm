package Crusher;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {
    $self->app->log->debug("Loading Server");

    # Load configuration from config file
    my $config = $self->plugin('NotYAMLConfig');

    $self->plugin(
        'OpenAPI',
        url =>
          $self->app->home->child('api')->child('crusher-api.yml')->to_string,
        schema => 'v3'
    );

    $self->plugin(
        SwaggerUI => {
            route => $self->routes()->any('api'),
            url   => "/api/v1",
            title => "Vehicle Crushers"
        }
    );

}

1;
