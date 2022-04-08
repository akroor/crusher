package Crusher::Controller::Vehicles;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use HTTP::Status qw(:constants);
use experimental qw(postderef);
use lib qw(/home/su/cc/startover/crushers/lib/Crusher/Controller/);
use db_ops;
use Data::Dumper;
use Mojolicious::Plugin::InputValidation;
use Mojo::Exception;

sub show_all ($self) {
    my $dbo = new db_ops();
    my $res = $dbo->exec_sql(
        sql => 'select * from vehicles',
        out => 'all',
    );

    return $self->render( openapi => $res );
}

sub vehicles_by_dt ($self) {

# iv_datetime from use Mojolicious::Plugin::InputValidation can be used to validate the input fields or parsedate from Timeparse module
    return unless $self->openapi->valid_input;

    my $from_dt = $self->validation->param('from_dt');
    my $to_dt   = $self->validation->param('to_dt');

    my $dbo = new db_ops();
    my $res = $dbo->exec_sql(
        sql => q{ select * from vehicles where mfr_date >= }
            . qq{ $from_dt }
            .  q{ and disp_date <= }
            . qq{ $to_dt },
        out => 'all',
    );

    return $self->render( openapi => $res );
}

sub add_vehicle ($self) {
    return unless $self->openapi->valid_input;

    my ( $make, $model, $mfr_dt, $plate, $plate_image, $vin, $status );

    $vin         = $self->validation->param('vin');
    $make        = $self->validation->param('make');
    $model       = $self->validation->param('model');
    $plate       = $self->validation->param('plate');
    $plate_image = $self->validation->param('plate_image');
    $status      = q{IN_PROGRESS};
    $mfr_dt      = $self->validation->param('mfr_dt');

    # Check if vin number already exists.
    die Mojo::Exception->new(qq{VIN [$vin] already exists.})
      if ( vin_check( 'vin' => $vin ) );

# my $img_path = upload_img($plate_image);
# upload_img() function will upload the image file locally on the file system and will return the path of the image
# sendfile() will be used to display it on the UI. I have not implemented the upload_img() function and it's corresponding end point.
# For now, I have hardcoded the path of the file.

    # Get plate image path #hardcoded for now
    my $img_path = q{'/var/crusher_images/abc.jpg'};

    # get make and model ids
    my $mk_sql =
qq { IFNULL((select make_id from makes_master where make_id = '$make'),1) };
    my $md_sql =
qq { IFNULL((select model_id from models_master where model_id = '$model'),1) };

    my $ins_sql =
        qq{ insert into vehicles values ( }
      . qq{ '$vin'  ,  }
      . qq{ $mk_sql ,  }
      . qq{ $md_sql ,  }
      . qq{ '$plate' , }
      . qq{ $img_path ,}
      . qq{ '$status' ,}
      . qq{ curdate() ,}
      . qq{ curdate() ,}
      . qq{ '$mfr_dt' ,}
      . q{ NULL } . q{ ) }
      ; # disposal_date Can have a indefinite date value too. e.g. 20991231. It desn't have to be a null.

# The above insert can also be implemented with execute( ?, ?) which will be more efficient over prepared statement.

    my $dbo = new db_ops()
      ;  # This db object can be reused. Creating a new one just for simplicity.
    my $res = $dbo->exec_sql(
        sql => $ins_sql,
        out => 'ins',
    );

    return $self->render( openapi =>
qq{Success inserted VIN [$vin], Make[$make], Model[$model], Plate[$plate], }
    );
}

sub vin_check {
    my %param = @_;
    my $res   = {};
    my $dbo   = new db_ops();
    $res = $dbo->exec_sql(
        sql => qq{ select 1 from vehicles where vin = } . qq{'$param{vin}'},
        out => 'single',
    );

    return $res->{1};
}

sub vehicles_by_vin ($self) {
    return unless $self->openapi->valid_input;

    my $vin = $self->validation->param('vin');

    my $dbo = new db_ops();
    my $res = $dbo->exec_sql(
        sql => q{ select * from vehicles where vin = } . qq{\'$vin\' },
        out => 'all',
    );

    return $self->render( openapi => $res );
}

sub get_all_makes($self)
{
return unless $self->openapi->valid_input;

my $dbo = new db_ops();
my $res = $dbo->exec_sql(
sql => q{select make, make_id from makes_master},
out => 'all'
);

return $self->render (openapi => $res);
}

sub get_models_for_make($self)
{
return unless $self->openapi->valid_input;

my $make_id = $self->validation->param('make_id');

my $dbo = new db_ops();
my $res = $dbo->exec_sql(
sql => q{select model, model_id from models_master where make_id = } . qq{$make_id},
out => 'all'
);

return $self->render (openapi => $res);
}


1;
